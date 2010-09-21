require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'http_client' do
  before(:each) do
    @http_client = HttpClient.new
    any_response = Struct.new(:code, :message, :headers, :body)
    @response = any_response.new(:code => 200, :message => "Ok", :headers => {:foo => ["baz" => "bar"], :body => {:a => "b"}})
  end
  describe 'send_request' do
    it 'should invoke a send request in the underlying http class with the given method, uri and data' do
      @http_client.class.should_receive(:put)
      @http_client.should_receive(:build_response).and_return(@response)
      @http_client.send_request(:put, "http://foo.bar", nil)

      @http_client.class.should_receive(:get)
      @http_client.should_receive(:build_response).and_return(@response)
      @http_client.send_request(:get, "http://foo.bar", nil)
    end
    it 'should invoke build response and return its output to the caller' do
      @http_client.should_receive(:build_response).and_return("response")
      @http_client.send_request(:put, "http://foo.bar", nil).should eql "response"
    end
    it 'should not fatal if expected data attribute is nil' do
      pending "TODO: pair this one"
      @http_client.should_receive(:build_response).and_return(@response)
      @http_client.send_request(:put, "http://foo.bar", nil).should_not raise_error
    end
  end

  describe 'build_response' do
    it 'should return a struct consisting of 4 symbols: :code, :message, :headers and :body with right types' do
      raw_response_struct = Struct.new(:code, :message, :headers, :body)
      response = raw_response_struct.new

      response.code    = 404
      response.message = "Hi Duffy Duck"
      response.headers = { :foo => ["bar" => "baz"] }
      response.body    = { :duffy => "duck" }

      @http_client.send(:build_response, response).to_s.should eql response.to_s
      @http_client.send(:build_response, response).code.should_not be_nil
      @http_client.send(:build_response, response).message.should_not be_nil
      @http_client.send(:build_response, response).body.should_not be_nil
      @http_client.send(:build_response, response).headers.should_not be_nil
    end
  end
end
