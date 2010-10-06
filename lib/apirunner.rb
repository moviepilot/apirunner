APIRUNNER_ROOT=File.dirname(__FILE__) + "/.."
require 'api_runner'
require 'string_ext'
module Apirunner
  require 'apirunner/railtie' if defined?(Rails)
end
