class ApiRunner
  require 'yaml'
  require 'expectation_matcher'
  require 'http_client'

  # initializes the object, loads environment, build base_uri
  def initialize(env)
    @http_client = HttpClient.new
    @spec = []
    @errors = []
    @excludes = []
    load_config(env)
    load_excludes(env)
    load_url_spec
    @expectation = Api1v0ExpectationMatcher.new(@excludes)
  end

  # checks servers availability and invokes test cases
  def run
    if server_is_available?
      run_tests
      @errors.try(:each_with_index) do |error, index|
        puts("\n\nError (#{index+1}): #{error}")
      end
    else
      puts("Server #{@host} seems to be unavailable!")
    end
  end

  protected

  # runs all testcases that are provided by the testclass an fills errors if there are any
  def run_tests
    @spec.each do |test_case|
      response = send_request(test_case['request']['method'].downcase.to_sym, target_uri(test_case['request']['path']), {:body => test_case['request']['body'].to_json})
      @expectation.test_types.each do |test_type|
        test = @expectation.check(test_type, response, test_case)
        if not test.succeeded
          @errors << test.error
          putc "F"
          break
        else
          putc "." if test_type == @expectation.test_types.last
        end
      end
    end
  end

  # sends http request and fetches response using the given http client
  def send_request(method, uri, data)
    @http_client.send_request(method, uri, data)
  end

  # builds target uri from base uri generated of host port and namespace as well as the ressource path
  def target_uri(ressource_path)
    "#{@protocol}://#{@host}:#{@port}/#{@namespace}" + ressource_path
  end

  # returns true if server is available
  def server_is_available?
    !@http_client.send_request(:get, "#{@protocol}://#{@host}:#{@port}", {:timeout => 5}).nil?
  end

  # loads environment config data from yaml file
  def load_config(env)
    config = YAML.load_file("#{Rails.root}/vendor/plugins/telekom_api/config/api_runner.yaml")
    config[env.to_s].each { |key, value| instance_variable_set("@#{key}", value) }
  end

  # loads spec cases from yaml files
  def load_url_spec
    path = "vendor/plugins/telekom_api/spec/api_runner/"
    Dir.new(path).entries.each do |dir_entry|
      @spec.push *YAML.load_file(path+dir_entry) if not (File.directory? dir_entry or dir_entry.match(/^\./) or dir_entry.match(/excludes/))
    end
  end

  # loads and parses items that need to be excluded from the checks in certain environments
  def load_excludes(env)
    excludes_file = "vendor/plugins/telekom_api/spec/api_runner/excludes.yml"
    @excludes = YAML.load_file(excludes_file).detect{ |a| a.first == env.to_s }[1]["excludes"]
  end
end

