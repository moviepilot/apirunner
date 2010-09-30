class ExpectationMatcher
  require 'result'
  require 'nokogiri'
  require 'JSON'
  require 'checker'
  require 'plugins/response_json_syntax_checker'
  require 'plugins/response_header_checker'
  require 'plugins/response_code_checker'
  require 'plugins/response_body_checker'

  def initialize(excludes=nil)
    @test_types = [:response_code, :response_json_syntax, :response_header, :response_body]
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

private

  # matches the given response code
  def response_code(response, testcase)
    ResponseCodeChecker.new(testcase, response).check
  end

  # checks the format of the given data of JSON conformity
  def response_json_syntax(response, testcase)
    ResponseJsonSyntaxChecker.new(testcase, response).check
  end

  # matches the given response header
  def response_header(response, testcase)
    ResponseHeaderChecker.new(testcase, response, @excludes).check
  end

  # matches the given attributes and values against the ones from the response body
  def response_body(response, testcase)
    ResponseBodyChecker.new(testcase, response, @excludes).check
  end
end
