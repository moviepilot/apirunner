class HttpClient
  require 'net/http'

  def initialize(host, port, namespace)
    @http = Net::HTTP.new(host, port)
    @host = host
    @port = port
    @namespace = namespace
  end

  def send_request(method, resource, data=nil)
    build_response(self.send(method.to_s.downcase, resource, data))
  end

  protected

  # returns struct containing response.code, headers, body and message
  # this is only for easily interfaceing another http client
  def build_response(raw_response)
    response_struct = Struct.new(:code, :message, :headers, :body)
    response = response_struct.new
    response.code = raw_response.code
    response.message = raw_response.message
    response.body = raw_response.body
    response.headers = raw_response.header
    response
  end

  def get(resource, params)
    request = Net::HTTP::Get.new(resource_path(resource), initheader = {'Content-Type' =>'application/json'})
    response = @http.request(request)
    return response
  end

  def put(resource, data)
    request = Net::HTTP::Put.new(resource_path(resource), initheader = {'Content-Type' =>'application/json'})
    request.body = data.to_json
    response = @http.request(request)
  end

  def post(resource, data)
    request = Net::HTTP::Post.new(resource_path(resource), initheader = {'Content-Type' =>'application/json'})
    request.body = data.to_json
    response = @http.request(request)
  end


  def delete(resource, params)
    request = Net::HTTP::Delete.new(resource_path(resource), initheader = {'Content-Type' =>'application/json'})
    response = @http.request(request)
  end

  def resource_path(resource)
    "/" + @namespace + resource
  end
end


class HttPartyClient
  require 'httparty'
  include HTTParty

  # sends http request with given method, uri and data and returns servers response
  def send_request(method, uri, data=nil)
    options = { :body => data.to_json, :format => :json }
    build_response(self.class.send(method, uri, options))
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

