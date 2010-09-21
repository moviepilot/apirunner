require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'apirunner' do
  before(:each) do
    ApiRunner.stub(:config_file).and_return("examples/config/api_runner.yml")
    ApiRunner.stub(:excludes_file).and_return("examples/test/api_runner/excludes.yml")
    ApiRunner.stub(:spec_path).and_return("examples/test/api_runner/")
    @a = ApiRunner.new(:local)
  end
  describe 'initialize' do
    it 'should fill all instance variables' do
      @a.instance_variable_get(:@protocol).should eql "http"
      @a.instance_variable_get(:@host).should eql "localhost"
      @a.instance_variable_get(:@port).should eql 3000
      @a.instance_variable_get(:@namespace).should eql "api1v0"
    end
    it 'should fill @excludes' do
      @a.instance_variable_get(:@excludes).should_not be_nil
      @a.instance_variable_get(:@excludes).should be_a(Array)
      @a.instance_variable_get(:@excludes).include?("content-length").should be_true
      @a.instance_variable_get(:@excludes).include?("notthere").should be_false
    end
    it 'should fill @spec'
    it 'should instantiate an http client into @http_client' do
      @a.instance_variable_get(:@http_client).should be_a(HttpClient)
    end
    it 'should instantiate an expectation_matcher into @expectation' do
      @a.instance_variable_get(:@expectation).should be_a(ExpectationMatcher)
    end
  end

  describe 'run_tests' do
    it 'should send a request for every given testcase'
    it 'should run a test for every test_type'
    it 'should output an "F" if an error occured'
    it 'should save an error message in @errors if an error occured'
    it 'should output a "." if all test_types of a certain test_case passed'
  end

  describe 'send_request' do
    it 'should invoke send_request at the @http_client with the appropiate method, uri and data'
  end

  describe 'target_uri' do
    it 'should create a correct target uri from existing instance variables'
  end

  describe 'server_is_available?' do
    it 'should return true if the requested server is available'
    it 'should return false if the given server is not available'
  end

  describe 'load_config' do
    it 'should load the configuration from a YAML file'
    it 'should put the config into certain instance variables'
  end

  describe 'load_url_spec' do
    it 'should load the URL spec from a YAML file'
    it 'should create an array of test_cases in @spec instance variable'
  end

  describe 'load_excludes' do
    it 'should load the excludes from a yaml file'
    it 'should populate @excludes instance variable with the excludes from the YAML file'
    it 'should make sure that @excludes is an array'
  end
end
