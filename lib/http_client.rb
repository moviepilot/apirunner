require 'curl_command_generator'

class HttpClient
  include ::CurlCommandGenerator

  require 'net/http'
  require "cgi"
  require "benchmark"

  def initialize(protocol, host, port, namespace)
    @http = Net::HTTP.new(host, port)
    @protocol = protocol
    @host = host
    @port = port
    @namespace = namespace
  end

  def send_request(method, resource, headers=nil, data=nil, params=nil)
    runtime, response = self.send(method.to_s.downcase, headers, resource, data, params)
    build_response(response, runtime, method, resource, params)
  end

  protected

  # returns struct containing response.code, headers, body and message
  # this is only for easily interfaceing another http client
  def build_response(raw_response, runtime, method, resource, params)
    response_struct = Struct.new(:code, :message, :headers, :body, :runtime, :fully_qualified_path)
    response = response_struct.new
    response.code = raw_response.code
    response.message = raw_response.message
    response.body = raw_response.body
    response.headers = raw_response.to_hash.keys.inject({}){ |hash, key| 
      value = raw_response.to_hash[key][0]
      hash[key.to_s.downcase] = value
      if value =~ /=/
        sub_values = value.tr(","," ").split(" ").select{|x| x =~ /=/}
        sub_values.each do |sub_value|
          s_key, s_value = sub_value.split("=")
          hash["#{key}[#{s_key}]"] = s_value
        end
      end

      hash
    }
    response.runtime = runtime
    response.fully_qualified_path = (method == "GET" ? build_uri(resource, params).request_uri : resource_path(resource))
    response
  end

  # sends GET request and returns response
  def get(headers, resource, data, params)
    puts curlize( build_uri(resource, params), :headers => headers, :method => :get, :body => data) if ENV['VERBOSE']
    request = Net::HTTP::Get.new(build_uri(resource, params).request_uri, headers)
    return Benchmark.realtime{ @response = @http.request(request) }, @response
  end

  # sends PUT request and returns response
  def put(headers, resource, data, params)
    puts curlize( build_uri(resource, params), :headers => headers, :method => :put, :body => data) if ENV['VERBOSE']
    request = Net::HTTP::Put.new(resource_path(resource), headers)
    request.body = data.to_json
    return Benchmark.realtime{ @response = @http.request(request) }, @response
  end

  # sends POST request and returns response
  def post(headers, resource, data, params)
    puts curlize( build_uri(resource, params), :headers => headers, :method => :post, :body => data) if ENV['VERBOSE']
    request = Net::HTTP::Post.new(resource_path(resource), headers)
    request.body = data.to_json
    return Benchmark.realtime{ @response = @http.request(request) }, @response
  end

  # sends DELETE request and returns response
  def delete(headers, resource, data, params)
    puts curlize( build_uri(resource, params), :headers => headers, :method => :delete, :body => data) if ENV['VERBOSE']
    request = Net::HTTP::Delete.new(resource_path(resource), headers)
    return Benchmark.realtime{ @response = @http.request(request) }, @response
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
    uri.query = params.collect{ |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.reverse.join('&') if not params.nil?
    uri.path = resource_path(resource)
    uri
  end
end
