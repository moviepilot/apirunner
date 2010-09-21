require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'ExpectationMatcher' do
  describe 'regex_matches?' do
    it 'should return true if given regex matches the given string' do
      ExpectationMatcher.new.send(:regex_matches?, "/^\\d{2}$/", "12").should be_true
    end
    it 'should return false if the given regex does not match the given string' do
      ExpectationMatcher.new.send(:regex_matches?, "/^\\d{2}$/", "133").should be_false
    end
  end

  describe 'testtypes' do
    it 'should return the available testtypes of the class'
    it 'should at least return one testtype'
    it 'should return an array of symbols'
    it 'should not return nil'
  end

  describe 'check' do
    it 'should invoke http client with the given method, response and testcase'
  end

  describe 'response_code' do
    it 'should return a struct representing success if the given response code matches the expected one'
    it 'should return a struct representing failure if the given repsonse code does not match the expected one'
    it 'should return a result struct'
  end

  describe 'response_body_format' do
    it 'should return a struct representing success if the given response body is nil, cause this is allowed'
    it 'should return the given response body in JSON format, if a valid JSON string is given to check'
    it 'should not fatal but return false, if the given response body is no valid JSON'
    it 'should return a result struct'
  end

  describe 'response_headers' do
    it 'should return a struct representing success, if one certain expected header value matches the response header'
    it 'should return a struct representing success, if more than one expected header values match the ones in the repsonse header'
    it 'should even return a struct representing success if the response header contains more values than the excpected'
    it 'should return a struct representing an error, if one single expected header value does not match the one in response'
    it 'should return a struct representing an error, if one of more expected header values does not match the corresponding one in the response'
    it 'should return a struct representing success, if the expected header is nil - no expectation exists'
    it 'should return a result struct'
  end

  describe 'response_body' do
    it 'should check something'
    it 'should return a result struct'
  end

  describe 'matcher_pathes_from' do
    it 'should return pathes to all leaves of a given tree'
    it 'should return relative pathes in case the tree included Array in the underlying JSON structure'
    it 'should return an array of strings'
  end

  describe 'relative_path' do
    it 'should substitute an absolute addressing in a given path'
    it 'should substitute more than one absolute adressing in a given path'
    it 'should return a string'
  end

  describe 'excluded?' do
    it 'should return true if the given string is present in the @excludes instance variable of the class'
  end

  describe 'is_regex?' do
    it 'should return true if the given string seems to be a regular expression'
    it 'should return false if the given string does not seem to be a regular expression'
  end

  describe 'regex_matches?' do
    it 'should return true if the given regular expression matches the given value'
    it 'should return false if the giveb reular expression does not match the given value'
  end

  describe 'string_matches?' do
    it 'should return true if the given string matches the given value'
    it 'should return false if the given string does not match the given value'
  end

  describe 'valid_json?' do
    it 'should return true if the given response body consists of valid JSON'
    it 'should return true if the given response body is nil'
    it 'should return false if the given response body consists of anything else but valid JSON'
  end
end

