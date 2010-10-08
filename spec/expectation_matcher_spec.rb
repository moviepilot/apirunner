require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'ExpectationMatcher' do
  describe "initialize" do
    it "should have a properly filled instance variable @excludes after instanciation" do
      @e = ExpectationMatcher.new(["exclude1","exclude2","exclude3"])
      @e.instance_variable_get(:@excludes).should be_a(Array)
      @e.instance_variable_get(:@excludes).size.should == 3
      @e.instance_variable_get(:@excludes)[0].should eql "exclude1"
    end
    it "should habe an empty array in @excludes if no excludes were given" do
      @e = ExpectationMatcher.new()
      @e.instance_variable_get(:@excludes).should be_a(Array)
      @e.instance_variable_get(:@excludes).size.should == 0
    end
  end
  describe "check" do
    it "should invoke check at the given plugin" do
      @e = ExpectationMatcher.new
      @e.should_receive(:test_plugin).once.with({ :response => "1" }, { :testcase => "2" })
      @e.check("TestPlugin", { :response => "1"}, { :testcase => "2" })
    end
  end
  describe "self.initialize_plugins" do
    it "should create private invocation methods for every plugin" do
      pending "TODO"
      ExpectationMatcher.should_receive(:available_plugins).and_return(["PluginNoOne", "PluginNoTwo", "PluginNoThree"])
      @e = ExpectationMatcher.new
      # FIXME private methods
      @e.should respond_to(:plugin_no_one)
      @e.should respond_to(:plugin_no_two)
      @e.should respond_to(:plugin_no_three)
    end
  end
end

