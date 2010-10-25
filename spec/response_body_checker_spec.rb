require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ResponseBodyChecker" do
  describe "relative_path" do
    it 'should substitute an absolute addressing in a given path' do
      path = "/bla/foo/values[6]/duffy/duck"
      ResponseBodyChecker.new({},{}).send(:relative_path, path).should eql "/bla/foo/*/duffy/duck"
    end
    it 'should substitute more than one absolute adressing in a given path' do
      path = "/bla/foo/values[6]/duffy/friends[1]/duck"
      ResponseBodyChecker.new({},{}).send(:relative_path, path).should eql "/bla/foo/*/duffy/*/duck"
    end
    it "should substiture at the end of the path too" do
      # pending "Had to revert the code change, caused a bug in tree parsing"
      path = "/bla/foo/values[6]/duffy/friends[1]/duck/ibizas[7]"
      ResponseBodyChecker.new({}, {}).send(:relative_path, path).should eql "/bla/foo/*/duffy/*/duck/*"
    end
    it 'should return a string' do
      path = "/bla/foo/values[6]/duffy/friends[1]/duck"
     ResponseBodyChecker.new({},{}).send(:relative_path, path).should be_a(String)
    end
  end
end
