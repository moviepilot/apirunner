require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "result" do
  before(:all) do
    @t = Testcase.new({},{})
    @t.error_message = "error message"
    @t.succeeded = true
  end
  describe "honk_in" do
  end
  describe "success?" do
    it "should return true if succeeded is set to true"
    it "should return false if succeeded is set to false"
  end
  describe "rspec" do
    it ""
  end
  describe "verbose_on_error" do

  end
  describe "verbose_on_success" do

  end
  describe "verbose_with_curl" do

  end
  describe "be_verbose" do

  end
  describe "result_case" do

  end
  describe "color_print" do

  end
  describe "ansi_colors" do

  end
end

