require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'json'
require 'nokogiri'

describe 'ExpectationMatcher' do
  before(:each) do
    @em = ExpectationMatcher.new
  end
  describe 'regex_matches?' do
    it 'should return true if given regex matches the given string' do
      ExpectationMatcher.new.send(:regex_matches?, "/^\\d{2}$/", "12").should be_true
    end
    it 'should return false if the given regex does not match the given string' do
      ExpectationMatcher.new.send(:regex_matches?, "/^\\d{2}$/", "133").should be_false
    end
  end

  describe 'testtypes' do
    it 'should return the available testtypes of the class' do
      @em.test_types.should eql ([:response_code, :response_body_format, :response_headers, :response_body])
    end
    it 'should at least return one testtype' do
      @em.test_types.size.should >= 1
    end
    it 'should return an array of symbols' do
      @em.test_types.should be_a(Array)
      @em.test_types.each do |type|
        type.should be_a(Symbol)
      end
    end
    it 'should not return nil' do
      @em.test_types.should_not be_nil
    end
  end

  describe 'check' do
    it 'should invoke http client with the given method, response and testcase' do
      @em = ExpectationMatcher.new
      @em.should_receive(:put)
      @em.check(:put, {}, [])
      @em.should_receive(:post)
      @em.check(:post, {}, [])
      @em.should_receive(:get)
      @em.check(:get, {}, [])
      @em.should_receive(:delete)
      @em.check(:delete, {}, [])
    end
  end

  describe 'response_code' do
    it 'should return a struct representing success if the given response code matches the expected one' do
      response_struct = Struct.new(:code, :message, :headers, :body)
      response = response_struct.new
      response.code = 404
      testcase = { 'response_expectation' => { 'status_code' => 404 } }
      @em.send(:response_code, response, testcase).should be_a(Struct)
      @em.send(:response_code, response, testcase).succeeded.should be_true
      @em.send(:response_code, response, testcase).error.should be_nil
    end
    it 'should return a struct representing failure if the given repsonse code does not match the expected one' do
      response_struct = Struct.new(:code, :message, :headers, :body)
      response = response_struct.new
      response.code = 400
      testcase = { 'response_expectation' => { 'status_code' => 404 } }
      @em.send(:response_code, response, testcase).should be_a(Struct)
      @em.send(:response_code, response, testcase).succeeded.should be_false
      @em.send(:response_code, response, testcase).error.should_not be_nil
    end
  end

  describe 'response_body_format' do
    before(:each) do
      response_struct = Struct.new(:code, :message, :headers, :body)
      @response = response_struct.new
    end
    it 'should return a struct representing success if the given response body is nil, cause this is allowed' do
      @response.body = nil
      @em.send(:response_body_format, @response, {}).should be_a(Struct)
      @em.send(:response_body_format, @response, {}).succeeded.should be_true
      @em.send(:response_body_format, @response, {}).error.should be_nil
    end
    it 'should return the given response body in JSON format, if a valid JSON string is given to check' do
      @response.body = {:fooz => "baaz"}.to_json
      @em.send(:response_body_format, @response, {}).should be_a(Struct)
      @em.send(:response_body_format, @response, {}).succeeded.should be_true
      @em.send(:response_body_format, @response, {}).error.should be_nil
    end
    it 'should not fatal but return false, if the given response body is no valid JSON' do
      @response.body = "foozbaz"
      @em.send(:response_body_format, @response, {}).should be_a(Struct)
      @em.send(:response_body_format, @response, {}).succeeded.should be_false
      @em.send(:response_body_format, @response, {}).error.should_not be_nil
    end
  end

  describe 'response_headers' do
    before(:each) do
      response_struct = Struct.new(:code, :message, :headers, :body)
      @response = response_struct.new
    end
    it 'should return a struct representing success, if one certain expected header value matches the response header' do
      @response.headers = {"content-type"=>["text/html; charset=utf-8"], "cache-control"=>["no-cache"], "x-runtime"=>["0.340116"], "server"=>["WEBrick/1.3.1 (Ruby/1.9.2/2010-08-18)"], "date"=>["Tue, 21 Sep 2010 11:33:05 GMT"], "content-length"=>["149"], "connection"=>["close"], "Last-Modified" => "2010-10-01 23:23:23"}
      testcase = { 'response_expectation' => { 'headers' => {"Last-Modified"=>"/.*/"} } }
      @em.send(:response_headers, @response, testcase).should be_a(Struct)
      @em.send(:response_headers, @response, testcase).succeeded.should be_true
      @em.send(:response_headers, @response, testcase).error.should be_nil
    end
    it 'should return a struct representing success, if more than one expected header values match the ones in the repsonse header' do
      pending "TODO: pair this one"
    end
    it 'should even return a struct representing success if the response header contains more values than the excpected' do
      pending "TODO: pair this one"
    end
    it 'should return a struct representing an error, if one single expected header value does not match the one in response' do
      pending "TODO: pair this one"
    end
    it 'should return a struct representing an error, if one of more expected header values does not match the corresponding one in the response' do
      pending "TODO: pair this one"
    end
    it 'should return a struct representing success, if the expected header is nil - no expectation exists' do
      pending "TODO: pair this one"
      testcase = { 'response_expectation' => { 'headers' => nil } }
      @em.send(:response_headers, @response, testcase).should be_a(Struct)
      @em.send(:response_headers, @response, testcase).succeeded.should be_true
      @em.send(:response_headers, @response, testcase).error.should be_nil
    end
  end

  describe 'response_body' do
    it 'should check something'
    it 'should return a result struct'
  end

  describe 'matcher_pathes_from' do
    it 'should return pathes to all leaves of a given tree including relative pathes in case of arrays in the JSON' do
      xml_tree = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><hash><bla>laber</bla><foo><values type=\"array\"><value><a>1</a></value><value><b type=\"integer\">2</b></value><value><c>/.*/</c></value></values></foo><bar>baz</bar></hash>"
      tree = Nokogiri::XML(xml_tree)
      @em.send(:matcher_pathes_from, tree).should be_a(Array)
      @em.send(:matcher_pathes_from, tree).include?("/hash/bla").should be_true
      @em.send(:matcher_pathes_from, tree).include?("/hash/foo/values/*/a").should be_true
      @em.send(:matcher_pathes_from, tree).include?("/hash/foo/values/*/b").should be_true
      @em.send(:matcher_pathes_from, tree).include?("/hash/foo/values/*/c").should be_true
      @em.send(:matcher_pathes_from, tree).include?("/hash/bar").should be_true
      @em.send(:matcher_pathes_from, tree).each do |path|
        path.should be_a(String)
      end
    end
  end

  describe 'relative_path' do
    it 'should substitute an absolute addressing in a given path' do
      path = "/bla/foo/values[6]/duffy/duck"
      @em.send(:relative_path, path).should eql "/bla/foo/*/duffy/duck"
    end
    it 'should substitute more than one absolute adressing in a given path' do
      path = "/bla/foo/values[6]/duffy/friends[1]/duck"
      @em.send(:relative_path, path).should eql "/bla/foo/*/duffy/*/duck"
    end
    it 'should return a string' do
      path = "/bla/foo/values[6]/duffy/friends[1]/duck"
      @em.send(:relative_path, path).should be_a(String)
    end
  end

  describe 'excluded?' do
    before(:each) do
      @em = ExpectationMatcher.new(['foo', 'bar'])
    end
    it 'should return true if the given string is present in the @excludes instance variable of the class' do
      @em.send(:excluded?, 'foo').should be_true
    end
    it 'should return false if the given string is not present in the @excludes instance variable of the class' do
      @em.send(:excluded?, 'fooz').should be_false
    end
  end

  describe 'is_regex?' do
    it 'should return true if the given string seems to be a regular expression' do
      string = "/^\d{3}$/"
      @em.send(:is_regex?, string).should be_true
    end
    it 'should return false if the given string does not seem to be a regular expression' do
      string = "fooz"
      @em.send(:is_regex?, string).should be_false
      string = "/fooz"
      @em.send(:is_regex?, string).should be_false
      string = "fooz/"
      @em.send(:is_regex?, string).should be_false
    end
  end

  describe 'regex_matches?' do
    it 'should return true if the given regular expression matches the given value' do
      regex = "^\\d{2}$"
      value = "12"
      @em.send(:regex_matches?, regex, value).should be_true
    end
    it 'should return false if the giveb reular expression does not match the given value' do
      regex = "^\\d{2}$"
      value = "123"
      @em.send(:regex_matches?, regex, value).should be_false
      value = "foo"
      @em.send(:regex_matches?, regex, value).should be_false
    end
  end

  describe 'string_matches?' do
    it 'should return true if the given string matches the given value' do
      string = "bar"
      value = "bar"
      @em.send(:string_matches?, string, value).should be_true
    end
    it 'should return false if the given string does not match the given value' do
      string = "bar"
      value = "foo"
      @em.send(:string_matches?, string, value).should be_false
    end
  end

  describe 'valid_json?' do
    it 'should return true if the given response body consists of valid JSON' do
      validateable = { :foo => "bar" }.to_json
      @em.send(:valid_json?, validateable).should be_true
    end
    it 'should return true if the given response body is nil' do
      @em.send(:valid_json?, nil).should be_true
    end
    it 'should return false if the given response body consists of anything else but valid JSON' do
      @em.send(:valid_json?, "foobar").should be_false
    end
  end
end

