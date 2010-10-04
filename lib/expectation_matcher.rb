class ExpectationMatcher
  require 'result'
  require 'checker'

  # dynamically load plugins
  dir = File.dirname(__FILE__) + '/plugins/'
  $LOAD_PATH.unshift(dir)
  Dir[File.join(dir, "*.rb")].each {|file| require File.basename(file) }

  def initialize(excludes=nil)
    @excludes = excludes || []
  end

  # dispatches incoming matching requests
  def check(plugin, response, testcase)
    self.send(plugin.underscore, response, testcase)
  end

  # dynamically generates methods that invoke "check" on all available plugins
  def self.initialize_plugins
    Checker.available_plugins.each do |plugin|
      define_method(plugin.underscore) do |response, testcase|
        eval(plugin).new(testcase, response, @excludes).check
      end
      private plugin.underscore.to_sym
    end
  end

  initialize_plugins
end
