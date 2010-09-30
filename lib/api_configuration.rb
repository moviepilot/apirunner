class ApiConfiguration

  attr_accessor :protocol, :host, :namespace, :port, :verbosity, :priority

  # initializes a configuration object from given YAML file for given environment
  def initialize(raw_config, env)
    raw_config[env.to_s].each { |key, value| self.instance_variable_set("@#{key}", value) }
    self.verbosity = raw_config['general']['verbosity'].first
    self.priority = raw_config['general']['priority'] || 0
    self
  end

end

