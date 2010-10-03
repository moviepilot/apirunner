class ExpectationMatcher
  require 'result'
  require 'checker'
  require 'plugins/response_json_syntax_checker'
  require 'plugins/response_header_checker'
  require 'plugins/response_code_checker'
  require 'plugins/response_body_checker'

  def initialize(excludes=nil)
    @excludes = excludes || []
  end

  # dispatches incoming matching requests
  def check(method, response, testcase)
    self.send(method, response, testcase)
  end

  # dynamically generates methods that invoke "check" on all available plugins
  def self.initialize_plugins
    Checker.available_plugins.each do |plugin|
      define_method(plugin) do |response, testcase|
        eval(plugin.to_s.camelize).new(testcase, response, @excludes).check
      end
    end
  end

  initialize_plugins

  private
end
