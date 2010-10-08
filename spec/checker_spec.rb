require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'json'
require 'nokogiri'

describe "Checker" do
  describe "self.available_plugins" do
    it "should return an array of available plugins inheriting from self" do
      Checker.available_plugins.should be_a(Array)
      Checker.available_plugins.size.should_not == 0
    end
  end
  describe "relative_path" do
    it 'should substitute an absolute addressing in a given path' do
      pending "Move me"
      path = "/bla/foo/values[6]/duffy/duck"
      Checker.new({},{}).send(:relative_path, path).should eql "/bla/foo/*/duffy/duck"
    end
    it 'should substitute more than one absolute adressing in a given path' do
      pending "Move me"
      path = "/bla/foo/values[6]/duffy/friends[1]/duck"
      Checker.new({},{}).send(:relative_path, path).should eql "/bla/foo/*/duffy/*/duck"
    end
    it 'should return a string' do
      pending "Move me"
      path = "/bla/foo/values[6]/duffy/friends[1]/duck"
      Checker.new({},{}).send(:relative_path, path).should be_a(String)
    end
  end
  describe "excluded?" do
    it "should return true if a given item is not part of the instances exludes"
    it "should return false if a given item is part of the instances excludes"
  end
  describe "is_regex?" do
    it 'should return true if the given string seems to be a regular expression' do
      string = "/^\d{3}$/"
      Checker.new({},{}).send(:is_regex?, string).should be_true
    end
    it 'should return false if the given string does not seem to be a regular expression' do
      string = "fooz"
      Checker.new({},{}).send(:is_regex?, string).should be_false
      string = "/fooz"
      Checker.new({},{}).send(:is_regex?, string).should be_false
      string = "fooz/"
      Checker.new({},{}).send(:is_regex?, string).should be_false
    end
  end
  describe "regex_matches?" do
    it 'should return true if the given regular expression matches the given value' do
      regex = "^\\d{2}$"
      value = "12"
      Checker.new({},{}).send(:regex_matches?, regex, value).should be_true
    end
    it 'should return false if the giveb reular expression does not match the given value' do
      regex = "^\\d{2}$"
      value = "123"
      Checker.new({},{}).send(:regex_matches?, regex, value).should be_false
      value = "foo"
      Checker.new({},{}).send(:regex_matches?, regex, value).should be_false
    end
  end
  describe "string_matches?" do
    it 'should return true if the given string matches the given value' do
      string = "bar"
      value = "bar"
      Checker.new({},{}).send(:string_matches?, string, value).should be_true
    end
    it 'should return false if the given string does not match the given value' do
      string = "bar"
      value = "foo"
      Checker.new({},{}).send(:string_matches?, string, value).should be_false
    end
  end
  describe "valid_json?" do
    it 'should return true if the given response body consists of valid JSON' do
      validateable = { :foo => "bar" }.to_json
      Checker.new({},{}).send(:valid_json?, validateable).should be_true
    end
    it 'should return true if the given response body is nil' do
      Checker.new({},{}).send(:valid_json?, nil).should be_true
    end
    it 'should return false if the given response body consists of anything else but valid JSON' do
      Checker.new({},{}).send(:valid_json?, "foobar").should be_false
    end
  end
end

