class ApiConfiguration

  attr_accessor :protocol, :host, :namespace, :port, :verbosity, :priority, :substitution, :csv_mode

  # initializes a configuration object from given YAML file for given environment
  def initialize(raw_config, env)
    raw_config[env.to_s].each { |key, value| self.instance_variable_set("@#{key}", value) }
    self.verbosity = raw_config['general']['verbosity'].first
    self.priority = raw_config['general']['priority'] || 0
    self.substitution = raw_config['general']['substitution']
    self.csv_mode = raw_config['general']['csv_mode'].first rescue "none"
    self
  end
end

