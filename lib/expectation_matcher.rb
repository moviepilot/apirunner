class ExpectationMatcher
  require 'result'
  require 'nokogiri'
  require 'JSON'

  def initialize(excludes=nil)
    @test_types = [:response_code, :response_body_format, :response_headers, :response_body]
    @excludes = excludes || []
  end

  # returns the available test types if this matcher class
  def test_types
    return @test_types
  end

  # dispatches incoming matching requests
  def check(method, response, testcase)
    self.send(method, response, testcase)
  end

  protected

  # matches the given response code
  def response_code(response, testcase)
    result = Result.new(testcase, response)
    if not testcase['response_expectation']['status_code'].to_s == response.code.to_s
      result.succeeded = false
      result.error_message = " expected response code --#{testcase['response_expectation']['status_code']}--\n got response code --#{response.code}--"
    end
    result
  end

  # checks the format of the given data of JSON conformity
  def response_body_format(response, testcase)
    result_struct = Struct.new(:succeeded, :error)
    results = result_struct.new(:succeeded => true, :error => nil)
    result = Result.new(testcase, response)
    if not valid_json?(response.body)
      result.succeeded = false
      result.error_message = "expected valid JSON in body\n got --#{response.body[1..400]}--"
    end
    result
  end

  # matches the given response header
  def response_headers(response, testcase)
    result = Result.new(testcase, response)

    testcase['response_expectation']['headers'].each_pair do |header_name, header_value|
      if is_regex?(header_value)
        if not (excluded?(header_name) or regex_matches?(header_value, response.headers[header_name]))
          result.succeeded = false
          result.error_message = " expected header identifier --#{header_name}-- to match regex --#{header_value}--\n got --#{response.headers[header_name]}--"
        end
      else
        if not (excluded?(header_name) or string_matches?(header_value, response.headers[header_name]))
          result.succeeded = false
          result.error_message = " expected header identifier --#{header_name}-- to match --#{header_value}--\n got --#{response.headers[header_name]}--"
        end
      end
    end unless (testcase['response_expectation']['headers'].nil? or testcase['response_expectation']['headers'].empty?)
    return result
  end

  # matches the given attributes and values against the ones from the response body
  def response_body(response, testcase)
    result = Result.new(testcase, response)

    expected_body_hash = testcase['response_expectation']['body']

    # in case we have no body expectation we simply return success
    return result if expected_body_hash.nil?

    # in case the response body is nil or damaged we return an error
    begin
      responded_body_hash = JSON.parse(response.body)
    rescue
      result = Result.new(testcase, response)
      result.succeeded = false
      result.error_message = " expected response to have a body\n got raw body --#{response.body}-- which is nil or an unparseable hash"
      return result
    end

    # else we build trees from both body structures...
    expectation_tree = Nokogiri::XML(expected_body_hash.to_xml({ :indent => 0 }))
    response_tree = Nokogiri::XML(responded_body_hash.to_xml({ :indent => 0 }))

    # retrieve all the leafs pathes and match the leafs values using xpath
    matcher_pathes_from(expectation_tree).each do |path|
      debugger if testcase['name'] == "Check users watchlist afterwards"
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
    result
  end

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
    path.gsub(/\/([^\/]+)\[\d+\]\//i,"/*/")
  end

  # returns true if given attributes is an excluded item that does not have to be evaluated in this environment
  def excluded?(item)
    @excludes.include?(item)
  end

  # returns true if given string seems to be a regular expression
  def is_regex?(string)
    string.to_s.match(/^\/.+\/$/)
  end

  # returns true if the given regular expression matches the given value
  def regex_matches?(regex, value)
    regex = Regexp.compile( regex.gsub(/^\//, '').gsub(/\/$/,'') )
    !!value.to_s.match(regex)
  end

  # returns true if the given string exactly matches the given value
  def string_matches?(string, value)
    string.to_s == value.to_s
  end

  # parses output into JSON object
  def valid_json?(response_body)
    # responses may be nil, return true then
    return true if response_body.blank?
    # returns true if given response is valid json, else false
    JSON.parse(response_body.to_s) rescue false
  end
end
