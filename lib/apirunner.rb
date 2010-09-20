APIRUNNER_ROOT=File.dirname(__FILE__) + "/.."
module Apirunner
  require 'apirunner/railtie' if defined?(Rails)
end
