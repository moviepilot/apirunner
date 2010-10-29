module CurlCommandGenerator
  def curlize(url, options = {})
    options = {:method => :get, :body => nil, :headers => nil}.merge( options )

    "curl -i #{headers2args(options[:headers])} #{method2arg(options[:method])} #{body2arg(options[:body])} #{url}"
  end

  private
  def method2arg(method_name)
    method_name && [:get,:put,:delete,:post].include?(method_name.to_sym) ? "-X#{method_name.to_s.upcase}" : ""
  end

  def body2arg(body)
    body && body.is_a?(Hash) ? body.inject(""){|string, key_value| string += " -d\"#{key_value[0]}: #{escape_quotes(key_value[1])}\""} : ""
  end

  def headers2args(hash)
    hash ? hash.inject(""){|string, key_value| string += " -H\"#{key_value[0]}: #{escape_quotes(key_value[1])}\""} : ""
  end


  def escape_quotes(string)
    string.to_s.gsub(/"/, '\"')
  end
end
