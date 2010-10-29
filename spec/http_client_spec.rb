require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'http_client' do
  before(:each) do
    @http_client = HttpClient.new("http", "localhost", 3000, "namespace")
    any_response = Struct.new(:code, :message, :headers, :body)
    @response = any_response.new(:code => 200, :message => "Ok", :headers => {:foo => ["baz" => "bar"], :body => {:a => "b"}})
  end
  describe 'send_request' do
    it 'should invoke a PUT request in the underlying http class with the given method, uri and data' do
      @http_client.stub(:build_response).and_return(@response)
      @http_client.should_receive(:put).and_return(@response)
      @http_client.send_request(:put, "/path/to/resource", nil, { :data => "2" }, { :params => "3" })
    end
    it 'should invoke a GET request in the underlying http class with the given method, uri and data' do
      @http_client.stub(:build_response).and_return(@response)
      @http_client.should_receive(:get).and_return(@response)
      @http_client.send_request(:get, "/path/to/resource", nil, { :data => "2" }, { :params => "3" })
    end
    it 'should invoke a POST request in the underlying http class with the given method, uri and data' do
      @http_client.stub(:build_response).and_return(@response)
      @http_client.should_receive(:post).and_return(@response)
      @http_client.send_request(:post, "/path/to/resource", nil, { :data => "2" }, { :params => "3" })
    end
    it 'should invoke a DELETE request in the underlying http class with the given method, uri and data' do
      @http_client.stub(:build_response).and_return(@response)
      @http_client.should_receive(:delete).and_return(@response)
      @http_client.send_request(:delete, "/path/to/resource", nil, { :data => "2" }, { :params => "3" })
    end
  end
  describe 'build_response' do
    it 'should return a struct consisting of 4 symbols: :code, :message, :headers and :body with right types' do
      raw_response_struct = Struct.new(:code, :message, :headers, :body, :runtime, :fully_qualified_path)
      response = raw_response_struct.new
      response.code    = 404
      response.message = "Hi Duffy Duck"
      response.stub!(:to_hash).and_return({ :daisy => ["duck"] })
      response.body    = { :duffy => "duck" }
      response.runtime = 0.123456789
      response.fully_qualified_path = "/path/to/resource"
      @http_client.send(:build_response, response, 0.0, "GET", "resource", {}).code.should_not be_nil
      @http_client.send(:build_response, response, 0.0, "GET", "resource", {}).message.should_not be_nil
      @http_client.send(:build_response, response, 0.0, "GET", "resource", {}).body.should == {:duffy => "duck"}
      @http_client.send(:build_response, response, 0.0, "GET", "resource", {}).headers.should == {"daisy" => "duck"}
    end
  end
  describe "resource_path" do
    it "should return a resource path extended by the namespace if one is set" do
      @http_client.send(:resource_path, "/users/duffyduck").match(@http_client.instance_variable_get(:@namespace)).should_not be_nil
    end
    it "should return a correct resource path even if no namespace is set" do
      @http_client.instance_variable_set(:@namespace, nil)
      @http_client.send(:resource_path, "/users/duffyduck").match(/\/users\/duffyduck/).should_not be_nil
    end
  end
  describe "build_uri" do
    it "should return a correct uri from the given parameters" do
      @http_client.send(:build_uri,"/users/duffyduck").should_not be_nil
      @http_client.send(:build_uri,"/users/duffyduck").to_s.match(@http_client.instance_variable_get(:@protocol)).should_not be_nil
      @http_client.send(:build_uri,"/users/duffyduck").to_s.match(@http_client.instance_variable_get(:@host)).should_not be_nil
      @http_client.send(:build_uri,"/users/duffyduck").to_s.match(@http_client.instance_variable_get(:@port).to_s).should_not be_nil
      @http_client.send(:build_uri,"/users/duffyduck").to_s.match(@http_client.instance_variable_get(:@namespace)).should_not be_nil
    end
    it "should only include a port in uri if a port was specified or port was set to 80" do
      @http_client.instance_variable_set(:@port, nil)
      @http_client.send(:build_uri,"/users/duffyduck").to_s.match("80").should be_nil
      @http_client.instance_variable_set(:@port, 80)
      @http_client.send(:build_uri,"/users/duffyduck").to_s.match("80").should be_nil
    end
    it "should add given GET parameters in correct notation" do
      @http_client.send(:build_uri,"/users/duffyduck", {:param1 => "1", :param2 => "a"}).to_s.match(/\?param/).should_not be_nil
      @http_client.send(:build_uri,"/users/duffyduck", {:param1 => "1", :param2 => "a"}).to_s.match(/param1=1/).should_not be_nil
      @http_client.send(:build_uri,"/users/duffyduck", {:param1 => "1", :param2 => "a"}).to_s.match(/param2=a/).should_not be_nil
    end
  end
end
