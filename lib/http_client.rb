class HttpClient
  require 'httparty'
  include HTTParty

  # sends http request with given method, uri and data and returns servers response
  def send_request(method, uri, data=nil)
    build_response(self.class.send(method, uri, data ||= {}))
  end

  protected

  # returns struct containing response.code, headers, body and message
  # this is only for easily interfaceing another http client
  def build_response(raw_response)
    response_struct = Struct.new(:code, :message, :headers, :body)
    response = response_struct.new
    response.code = raw_response.code
    response.message = raw_response.message
    response.headers = raw_response.headers
    response.body = raw_response.body
    response
  end
end

