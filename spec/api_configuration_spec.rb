require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'initialize' do
  before(:each) do
    @config_hash = {
      "test" => {
        :a => 1,
        :b => 2,
        :protocol => "http",
        :host => "localhost",
        :port => 3000,
        :namespace => "namespace"
      },
      "general" => {
        "verbosity" => ["verbose", "unused"],
        "priority" => 10
      }
    }
  end

  it 'should set instance variables for each config key value pair' do
    @a = ApiConfiguration.new(@config_hash, "test")
    @a.instance_variable_get(:@a).should == 1
    @a.instance_variable_get(:@b).should == 2
    @a.instance_variable_get(:@protocol).should == "http"
    @a.instance_variable_get(:@host).should == "localhost"
    @a.instance_variable_get(:@port).should == 3000
    @a.instance_variable_get(:@namespace).should == "namespace"
  end

  it 'should set verbosity correctly' do
    @a = ApiConfiguration.new(@config_hash, "test")
    @a.instance_variable_get(:@verbosity).should == "verbose"
  end

  it 'should set priority correctly' do
    @a = ApiConfiguration.new(@config_hash, "test")
    @a.instance_variable_get(:@priority).should == 10
  end
end
