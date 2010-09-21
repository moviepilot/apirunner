require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'http_client' do
  describe 'send_request' do
    it 'should invoke a send request in the underlying http class with the given method, uri and data'
    it 'should not fatal if expected data attribute is nil'
    it 'should invoke build response and return its output to the caller'
  end

  describe 'build_response' do
    it 'should return a struct consisting of 4 symbols: :code, :message, :headers and :body with right types'
  end
end
