APIRUNNER_ROOT=File.dirname(__FILE__) + "/.."
require 'api_runner'
module Apirunner
  require 'apirunner/railtie' if defined?(Rails)
end
