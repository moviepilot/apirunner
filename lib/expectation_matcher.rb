class ExpectationMatcher
  require 'nokogiri'

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
    result_struct = Struct.new(:succeeded, :error)
    results = result_struct.new(:succeeded => true, :error => nil)
    if not testcase['response_expectation']['status_code'] == response.code
      results.succeeded = false
      results.error = "testcase '#{testcase['name']}'\n expected response code --#{testcase['response_expectation']['status_code']}--\n got response code --#{response.code}--"
    end
    results
  end

  # checks the format of the given data of JSON conformity
  # returns a structure containing return value and error if there is one
  def response_body_format(response, testcase)
    result_struct = Struct.new(:succeeded, :error)
    results = result_struct.new(:succeeded => true, :error => nil)
    if not valid_json?(response.body)
      results.succeeded = false
      results.error = "testcase '#{testcase['name']}'\n expected valid JSON in body\n got --#{response.body[1..400]}--"
    end
    results
  end

  # matches the given response header
  def response_headers(response, testcase)
    result_struct = Struct.new(:succeeded, :error)
    results = result_struct.new(:succeeded => true, :error => nil)

    debugger
    testcase['response_expectation']['headers'].try(:each_pair) do |header_name, header_value|
      if is_regex?(header_value)
        if not (excluded?(header_name) or regex_matches?(header_value, response.headers[header_name]))
          results.succeeded = false
          results.error = "testcase '#{testcase['name']}'\n expected header identifier --#{header_name}-- to match regex --#{header_value}--\n got --#{response.headers[header_name]}--"
        end
      else
        if not (excluded?(header_name) or string_matches?(header_value, response.headers[header_name]))
          results.succeeded = false
          results.error = "testcase '#{testcase['name']}'\n expected header identifier --#{header_name}-- to match --#{header_value}--\n got --#{response.headers[header_name]}--"
        end
      end
    end
    return results
  end

  # matches the given attributes and values against the ones from the response body
  def response_body(response, testcase)
    result_struct = Struct.new(:succeeded, :error)
    results = result_struct.new(:succeeded => true, :error => nil)

    expected_body_hash = testcase['response_expectation']['body']

    # in case we have no body expectation we simply return success
    return results if expected_body_hash.nil?

    # in case the response body is nil or damaged we return an error
    begin
      responded_body_hash = JSON.parse(response.body)
    rescue
      results.succeeded = false
      results.error = "testcase '#{testcase['name']}'\n expected response to have a body\n got raw body --#{response.body}-- which is nil or an unparseable hash"
      return results
    end

    # else we build trees from both body structures...
    expectation_tree = Nokogiri::XML(expected_body_hash.to_xml({ :indent => 0 }))
    response_tree = Nokogiri::XML(responded_body_hash.to_xml({ :indent => 0 }))

    # retrieve all the leafs pathes and match the leafs values using xpath
    matcher_pathes_from(expectation_tree).each do |path|
      expectation_node = expectation_tree.xpath(path).first
      response_node = response_tree.xpath(path).first

      # return error if response body does not have the expected entry
      if response_node.nil?
        results.succeeded = false
        results.error = "testcase '#{testcase['name']}'\n expected body to have identifier --#{expectation_node.name}--\n got nil"
        return results
      end

      # last but not least try the regex or direct match and return errors in case of any
      if is_regex?(expectation_node.text)
        if not (excluded?(expectation_node.name) or regex_matches?(expectation_node.text, response_node.text))
          results.succeeded = false
          results.error = "testcase '#{testcase['name']}'\n expected body identifier --#{expectation_node.name}-- to match regex --#{expectation_node.text}--\n got --#{response_node.text}--"
        end
      else
        if not (excluded?(expectation_node.name) or string_matches?(expectation_node.text, response_node.text))
          results.succeeded = false
          results.error = "testcase '#{testcase['name']}'\n expected body identifier --#{expectation_node.name}-- to match --#{expectation_node.text}--\n got --#{response_node.text}--"
        end
      end
    end
    results
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
