require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'http_client' do
  before(:each) do
    @http_client = HttpClient.new("http", "localhost", 3000, "namespace")
    any_response = Struct.new(:code, :message, :headers, :body)
    @response = any_response.new(:code => 200, :message => "Ok", :headers => {:foo => ["baz" => "bar"], :body => {:a => "b"}})
  end
  describe 'send_request' do
    it 'should invoke a PUT request in the underlying http class with the given method, uri and data' do
      @http_client.send_request(:put, "/path/to/resource", nil, { :data => "2" }, { :params => "3" })
      @http_client.should_receive(:build_response).and_return(@response)
      @http_client.should_receive(:put).and_return(@response)
    end
  end

  describe 'build_response' do
    it 'should return a struct consisting of 4 symbols: :code, :message, :headers and :body with right types' do
      raw_response_struct = Struct.new(:code, :message, :headers, :body)
      response = raw_response_struct.new

      response.code    = 404
      response.message = "Hi Duffy Duck"
      response.headers = "{\"foo\":[{\"bar\":\"baz\"}]}"
      response.body    = { :duffy => "duck" }

      @http_client.send(:build_response, response).to_s.should eql response.to_s
      @http_client.send(:build_response, response).code.should_not be_nil
      @http_client.send(:build_response, response).message.should_not be_nil
      @http_client.send(:build_response, response).body.should_not be_nil
      @http_client.send(:build_response, response).headers.should_not be_nil
    end
  end
end
