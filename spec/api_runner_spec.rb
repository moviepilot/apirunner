require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'apirunner' do
  describe 'initialize' do
    it 'should invoke load_config'
    it 'should invoke load_excludes'
    it 'should invoke load_url_spec'
    it 'should instantiate all nessecary instance variables'
    it 'should instantiate an http client into @http_client'
    it 'should instantiate an expectation_matcher into @expectation'
  end

  describe 'run' do
    it 'should first check if the server is available'
    it 'should run all the tests in @spec'
    it 'should not fatal if no errors occure'
    it 'should output errors, if some occure'
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
