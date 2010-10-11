require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "result" do
  before(:all) do
    @r = Result.new({ :name => "testcase_name" }, {})
  end
  describe "verbose_on_error" do
    it "should invoke be_verbose if an error occured" do
      @r.instance_variable_set(:@succeeded, false)
      @r.should_receive(:be_verbose).once
      @r.send(:verbose_on_error, 1)
    end
    it "should not invoke be_verbose if no error occured" do
      @r.instance_variable_set(:@succeeded, true)
      @r.should_receive(:be_verbose).exactly(0).times
      @r.send(:verbose_on_error, 1)
    end
  end
  describe "verbose_on_success" do
    it "should invoke be_verbose in case of an error" do
      @r.instance_variable_set(:@succeeded, false)
      @r.should_receive(:be_verbose).once
      @r.send(:verbose_on_success, 1)
    end
    it "should invoke be_verbose in case of no error too" do
      @r.instance_variable_set(:@succeeded, true)
      @r.should_receive(:be_verbose).once
      @r.send(:verbose_on_success, 1)
    end
  end
  describe "verbose_with_curl" do
    it "should invoke be_verbose in case of an error" do
      @r.instance_variable_set(:@succeeded, false)
      @r.should_receive(:be_verbose).once
      @r.send(:verbose_with_curl, 1)
    end
    it "should invoke be_verbose in case of no error too" do
      @r.instance_variable_set(:@succeeded, true)
      @r.should_receive(:be_verbose).once
      @r.send(:verbose_with_curl, 1)
    end
  end
end


