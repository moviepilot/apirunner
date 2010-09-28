class HttpClient
  require 'net/http'

  def initialize(host, port, namespace)
    @http = Net::HTTP.new(host, port)
    @host = host
    @port = port
    @namespace = namespace
  end

  def send_request(method, resource, headers=nil, data=nil)
    build_response(self.send(method.to_s.downcase, headers, resource, data))
  end

  protected

  # returns struct containing response.code, headers, body and message
  # this is only for easily interfaceing another http client
  def build_response(raw_response)
    debugger
    response_struct = Struct.new(:code, :message, :headers, :body)
    response = response_struct.new
    response.code = raw_response.code
    response.message = raw_response.message
    response.body = raw_response.body
    # response.headers = raw_response.header
    # TODO improve me!
    response.headers = JSON.parse(raw_response.header.to_json) rescue nil
    response
  end

  def get(headers, resource, params)
    request = Net::HTTP::Get.new(resource_path(resource), initheader = headers)
    @http.request(request)
  end

  def put(headers, resource, data)
    request = Net::HTTP::Put.new(resource_path(resource), initheader = headers)
    request.body = data.to_json
    @http.request(request)
  end

  def post(headers, resource, data)
    request = Net::HTTP::Post.new(resource_path(resource), initheader = headers)
    request.body = data.to_json
    @http.request(request)
  end


  def delete(headers, resource, params)
    request = Net::HTTP::Delete.new(resource_path(resource), initheader = headers)
    @http.request(request)
  end

  def resource_path(resource)
    "/" + @namespace + resource
  end
end

