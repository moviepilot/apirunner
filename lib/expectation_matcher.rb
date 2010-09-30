class ExpectationMatcher
  require 'result'
  require 'nokogiri'
  require 'JSON'
  require 'checker'
  require 'json_syntax_checker'
  require 'header_checker'
  require 'response_code_checker'
  require 'body_checker'

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
    ResponseCodeChecker.new(testcase, response).check
  end

  # checks the format of the given data of JSON conformity
  def response_body_format(response, testcase)
    JsonSyntaxChecker.new(testcase, response).check
  end

  # matches the given response header
  def response_headers(response, testcase)
    HeaderChecker.new(testcase, response, @excludes).check
  end

  # matches the given attributes and values against the ones from the response body
  def response_body(response, testcase)
    BodyChecker.new(testcase, response, @excludes).check
  end
end
