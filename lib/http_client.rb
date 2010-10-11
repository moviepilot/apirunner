class HttpClient
  require 'net/http'
  require "cgi"

  def initialize(protocol, host, port, namespace)
    @http = Net::HTTP.new(host, port)
    @protocol = protocol
    @host = host
    @port = port
    @namespace = namespace
  end

  def send_request(method, resource, headers=nil, data=nil, params=nil)
    build_response(self.send(method.to_s.downcase, headers, resource, data, params))
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
    response.headers = JSON.parse(raw_response.headers.to_json) rescue nil
    response
  end

  # sends GET request and returns response
  def get(headers, resource, data, params)
    request = Net::HTTP::Get.new(build_uri(resource, params).request_uri, initheader = headers)
    @http.request(request)
  end

  # sends PUT request and returns response
  def put(headers, resource, data, params)
    request = Net::HTTP::Put.new(resource_path(resource), initheader = headers)
    request.body = data.to_json
    @http.request(request)
  end

  # sends POST request and returns response
  def post(headers, resource, data, params)
    request = Net::HTTP::Post.new(resource_path(resource), initheader = headers)
    request.body = data.to_json
    @http.request(request)
  end

  # sends DELETE request and returns response
  def delete(headers, resource, data, params)
    request = Net::HTTP::Delete.new(resource_path(resource), initheader = headers)
    @http.request(request)
  end

  # redefines the resource path including the namespace
  def resource_path(resource)
    @namespace.nil? ? resource : "/" + @namespace + resource
  end

  # rebuild a uri in details, so that another protocol, host, port and GET params can be specified, after Net::HTTP was created
  def build_uri(resource, params=nil)
    uri = URI.parse(@protocol + "://" + @host + ((@port.nil? || @port != "80") ? ":#{@port}" : ""))
    uri.scheme = @protocol
    uri.host = @host
    uri.port = @port
    uri.query = "".concat(params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.reverse.join('&')) if not params.nil?
    uri.path = resource_path(resource)
    uri
  end
end
