class ApiRunner
  require 'yaml'
  require 'csv_writer'
  require 'string_ext' if not String.respond_to?(:underscore)
  require 'expectation_matcher'
  require 'http_client'
  require 'api_configuration'
  require 'testcase'
  require 'json'

  CONFIG_FILE = "config/api_runner.yml"
  SPEC_PATH = "test/api_runner/"
  EXCLUDES_FILE = "test/api_runner/excludes.yml"
  CSV_PATH = "tmp"

  # initializes the object, loads environment, build base_uri
  def initialize(env, performance=nil)
    @spec = []
    @results = []
    @excludes = []
    @configuration = ApiConfiguration.new(YAML.load_file(self.class.config_file), env)
    @configuration.verbosity = "performance" if performance
    load_excludes(env)
    load_url_spec
    @http_client = HttpClient.new(@configuration.protocol, @configuration.host, @configuration.port, @configuration.namespace)
    @expectation = ExpectationMatcher.new(@excludes)
    @csv_writer = CsvWriter.new(self.class.csv_path, env)
  end

  # checks servers availability and invokes test cases
  def run
    if server_is_available?
      run_tests
      @csv_writer.write(@configuration.csv_mode, @results) unless @results.empty?
      @results.each_with_index do |result, index|
        result.honk_in(@configuration.verbosity, index)
      end unless @results.empty?
    else
      puts("Server #{@configuration.host} seems to be unavailable!")
    end
    error_count = @results.select{ |r| !r.succeeded }.count
    puts "\n\nResults: I greatfully ran #{ @spec.size } test(s), \033[32m#{ @spec.size - error_count }\033[0m succeeded, \033[31m#{ error_count }\033[0m failed."
    return (error_count)
  end

  protected

  # runs all testcases that are provided by the testclass an fills errors if there are any
  def run_tests
    puts "Running exactly #{@spec.size} tests."
    @spec.each do |test_case|
      sleep test_case.wait_before_request
      response = send_request_for(test_case)
      Checker.available_plugins.each do |plugin|
        result = @expectation.check(plugin, response, test_case)
        if not result.success?
          putc "F"
          @results << result
          break
        else
          if plugin == Checker.available_plugins.last
            @results << result
            putc "."
          end
        end
      end
    end
  end

  # sends http request and fetches response using the given http client
  def send_request_for(testcase)
    @http_client.send_request(testcase.request['method'], testcase.request['path'], testcase.request['headers'], testcase.request['body'], testcase.request['parameters'])
  end

  # builds target uri from base uri generated of host port and namespace as well as the ressource path
  def target_uri
    "#{@configuration.protocol}://#{@configuration.host}"
  end

  # returns true if server is available
  def server_is_available?
    return true
    !@http_client.send_request(:get, "#{@configuration.protocol}://#{@configuration.host}:#{@configuration.port}", nil, {:timeout => 5}).nil?
  end

  # loads spec cases from yaml files
  def load_url_spec
    path = self.class.spec_path
    specs = []
    Dir.new(path).entries.sort.each do |dir_entry|
      specs.push *YAML.load_file(path+dir_entry) if not (File.directory? dir_entry or dir_entry.match(/^\./) or dir_entry.match(/excludes/))
    end
    @spec = Testcase.expand_specs(specs, @configuration)
  end

  # loads and parses items that need to be excluded from the checks in certain environments
  def load_excludes(env)
    excludes_file = self.class.excludes_file
    @excludes = YAML.load_file(excludes_file).detect{ |a| a.first == env.to_s }[1]["excludes"] rescue nil
  end

  # returns config files path and can be stubbed this way
  def self.config_file
    CONFIG_FILE
  end

  # returns path to spec files that can be stubbed for tests
  def self.spec_path
    SPEC_PATH
  end

  # returns excludes file path that can be stubbed
  def self.excludes_file
    EXCLUDES_FILE
  end
  
  # returns csv file path that can be stubbed
  def self.csv_path
    CSV_PATH
  end
end
