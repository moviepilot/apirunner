class Testcase
  require 'digest/md5'

  attr_reader :raw, :name, :request, :response_expectation, :wait_before_request
  @@configuration ||= nil

  def initialize(raw, substitution)
    @raw = raw
    @name = raw['name']
    @request = @raw['request']
    @response_expectation = @raw['response_expectation']
    @wait_before_request = @raw['wait_before_request'].nil? ? 0 : @raw['wait_before_request']
    create_resource_substitutes(substitution)
  end

  # creates an array of spec hashes by calling priorize, partition and explode_iterations
  # to prepare the specs, automagically create the ierting ones and partition them
  def self.expand_specs(specs, configuration)
    @@configuration = configuration
    objectize(partition(explode_iterations(priorize(specs))))
  end

  # returns an identifier of that testcase that should be unique
  def unique_identifier
   Digest::MD5.hexdigest(@name.to_s)[0..9]
  end

  private
  # explodes specs that include iterations and interpolates the iteration variable into all occuring @@ placeholders
  def self.explode_iterations(specs)
    return specs unless specs.detect{ |s| s['iterations']}
    exploded_specs = []
    specs.each do |spec|
      if spec['iterations'].nil?
        exploded_specs << spec
      else
        1.upto(spec['iterations'].to_i) do |i|
          exploded_specs << JSON.parse(spec.to_json.gsub(/@@/, "%07d" % i.to_s))
        end
      end
    end
    return exploded_specs
  end

  # converts the given array of raw testcases to an array of testcase objects
  def self.objectize(raw_specs)
    specs = []
    raw_specs.each do |spec|
      specs << self.new(spec, @@configuration.substitution)
    end
    specs
  end

  # returns only spec whose priority level is less or equals configures priority level
  # if no priority level is configured for the api runner, 0 is assumed
  # if no priority level ist configured for a story, 0 is assumed
  def self.priorize(specs)
    relevant_specs = []
    specs.each do |spec|
      relevant_specs << spec if spec['priority'].nil? or spec['priority'].to_i <= @@configuration.priority.to_i
    end
    relevant_specs
  end

  # partitions the spec if keywords like 'focus', 'until' or 'from exist'
  # and returns the relevant subset of specs that have to be tested then
  def self.partition(specs)
    relevant_specs = []
    specs.each do |spec|
      if spec['focus']
        relevant_specs << spec
        break
      elsif spec['until']
        relevant_specs = specs[0..specs.index(spec)]
        break
      elsif spec['from']
        relevant_specs = specs[specs.index(spec)..specs.size+1]
        break
      end
    end
    relevant_specs = specs if relevant_specs.empty?
    relevant_specs
  end

  # substitutes rersource names cause of race conditions in multiple system scenarios
  def create_resource_substitutes(substitution)
    substitution['substitutes'].each do |substitute|
      @request = JSON.parse(@request.to_json.gsub(substitute, substitution['prefix'] + substitute))
      @response_expectation = JSON.parse(@response_expectation.to_json.gsub(substitute, substitution['prefix'] + substitute))
    end unless substitution.nil?
  end

end
