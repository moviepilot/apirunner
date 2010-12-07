require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'apirunner' do
  before(:each) do
    ApiRunner.stub(:config_file).and_return("examples/config/api_runner.yml")
    ApiRunner.stub(:excludes_file).and_return("examples/test/api_runner/excludes.yml")
    ApiRunner.stub(:spec_path).and_return("examples/test/api_runner/")
    @a = ApiRunner.new(:local)
  end
  describe 'initialize' do
    it 'should fill all instance variables properly' do
      @a.instance_variable_get(:@spec).should be_a(Array)
      @a.instance_variable_get(:@spec).size.should == 167
      @a.instance_variable_get(:@results).should be_a(Array)
      @a.instance_variable_get(:@results).size.should == 0
      @a.instance_variable_get(:@configuration).should be_a(ApiConfiguration)
      @a.instance_variable_get(:@configuration).host.should == "localhost"
      @a.instance_variable_get(:@configuration).port.should == 3000
      @a.instance_variable_get(:@configuration).protocol.should == "http"
      @a.instance_variable_get(:@configuration).namespace.should == "api1v0"
      @a.instance_variable_get(:@configuration).verbosity.should == "verbose_on_error"
      @a.instance_variable_get(:@configuration).priority.should == 0
      @a.instance_variable_get(:@http_client).should be_a(HttpClient)
      @a.instance_variable_get(:@expectation).should be_a(ExpectationMatcher)
    end
    it 'should fill @excludes' do
      @a.instance_variable_get(:@excludes).should_not be_nil
      @a.instance_variable_get(:@excludes).should be_a(Array)
      @a.instance_variable_get(:@excludes).include?("content-length").should be_true
      @a.instance_variable_get(:@excludes).include?("notthere").should be_false
    end
    it 'should fill @spec' do
      @a.instance_variable_get(:@spec).should be_a(Array)
      @a.instance_variable_get(:@spec).size.should >= 1
    end
  end

  describe 'run_tests' do
    it 'should send a request for every given testcase' do
      pending "TODO"
      response = Result.new({},{})
      @a.should_receive(:server_is_available?).and_return true
      @a.should_receive(:send_request).exactly(@a.instance_variable_get(:@spec).size).times.and_return(response)
      @a.run
    end
    it 'should save an error message in @errors if an error occured' do
      pending "TODO"
      response = Result.new({},{})
      @a.should_receive(:server_is_available?).and_return true
      @a.should_receive(:send_request).exactly(@a.instance_variable_get(:@spec).size).times.and_return(response)
      @a.run
      @a.instance_variable_get(:@results).should_not be_nil
      @a.instance_variable_get(:@results).size.should_not == 0
    end
  end

  describe 'send_request' do
    it "should invoke send_request at the @http_client with appropiate method, path, headers, body and get-parameters" do
      pending "TODO"
      @a.instance_variable_get(:@http_client).should_receive(:send_request).and_return(Result.new({},{}))
      @a.send(:send_request_for,Testcase.new({}))
    end
  end

  describe 'target_uri' do
    it 'should create a correct target uri from existing instance variables' do
      @a.send(:target_uri).match(@a.instance_variable_get(:@configuration).protocol).should be_true
      @a.send(:target_uri).match(@a.instance_variable_get(:@configuration).host).should be_true
      @a.send(:target_uri).match("://").should be_true
    end
  end

  describe 'server_is_available?' do
    it 'should return true if the requested server is available'
    it 'should return false if the given server is not available'
  end
end
