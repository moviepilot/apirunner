class ResponseBodyChecker < Checker
  require 'nokogiri'

  def check
    result = Result.new(@testcase, @response)
    begin
      # special case: the whole body has to be matched via a regular expression
      if is_regex?(@testcase.response_expectation['body'])
        if not regex_matches?(@testcase.response_expectation['body'], @response.body)
          result.succeeded = false
          result.error_message = " expected the whole body to match regex --#{@testcase.response_expectation['body']}--\n got --#{@response.body}--"
        end
        return result
      end

      expected_body_hash = @testcase.response_expectation['body']

      # in case we have no body expectation we simply return success
      return result if expected_body_hash.nil?

      # in case the response body is nil or damaged we return an error
      begin
        responded_body_hash = JSON.parse(@response.body)
      rescue
        result = Result.new(@testcase, @response)
        result.succeeded = false
        result.error_message = " expected response to have a body\n got raw body --#{@response.body}-- which is nil or an unparseable hash"
        return result
      end

      # else we build trees from both body structures...
      expectation_tree = Nokogiri::XML(expected_body_hash.to_xml({ :indent => 0 }))
      response_tree = Nokogiri::XML(responded_body_hash.to_xml({ :indent => 0 }))

      # retrieve all the leafs pathes and match the leafs values using xpath
      matcher_pathes_from(expectation_tree).each do |path|
        expectation_node = expectation_tree.xpath(path).first
        response_node = response_tree.xpath(path).first

        # in some (not awesome) cases the root node occures as leaf, so we have to skip him here
        next if expectation_node.name == "hash"

        # return error if response body does not have the expected entry
        if response_node.nil?
          result.succeeded = false
          result.error_message = " expected body to have identifier --#{expectation_node.name}--\n got nil"
          return result
        end

        # last but not least try the regex or direct match and return errors in case of any
        if is_regex?(expectation_node.text)
          if not (excluded?(expectation_node.name) or regex_matches?(expectation_node.text, response_node.text))
            result.succeeded = false
            result.error_message = " expected body identifier --#{expectation_node.name}-- to match regex --#{expectation_node.text}--\n got --#{response_node.text}--"
          end
        else
          if not (excluded?(expectation_node.name) or string_matches?(expectation_node.text, response_node.text))
            result.succeeded = false
            result.error_message = " expected body identifier --#{expectation_node.name}-- to match --#{expectation_node.text}--\n got --#{response_node.text}--"
          end
        end
      end
    rescue
      result.succeeded = false
      result.error_message = " unexpected error while parsing testcase/response. Check your testcase format!"
    end
    result
  end

  private

  # recursively parses the tree and returns a set of relative pathes
  # that can be used to match the both trees leafs
  def matcher_pathes_from(node, pathes = nil)
    pathes ||= []
    if not node.children.blank?
      node.children.each do |sub_node|
        matcher_pathes_from(sub_node, pathes)
      end
    else
      pathes << relative_path(node.parent.path)
    end
    pathes
  end

  # returns relative path for matching the target tree of the response body
  # explicit array adressing is replaced by *
  def relative_path(path)
    # replace array referenced IN the path
    first_pass = path.gsub(/\/([^\/]+)\[\d+\]\//i,"/*/")
    # replace array references AT THE END of the path too
    first_pass.gsub(/\/([^\/]+)\[\d+\]$/,"/*")
  end
end
