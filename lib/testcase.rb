class Testcase

  attr_reader :raw, :name, :request, :response_expectation, :wait_before_request

  def initialize(raw, substitution)
    @raw = raw
    @name = raw['name']
    @request = @raw['request']
    @response_expectation = @raw['response_expectation']
    @wait_before_request = @raw['wait_before_request'].nil? ? 0 : @raw['wait_before_request']
    create_resource_substitutes(substitution)
  end

  # substitutes rersource names cause of race conditions in multiple system scenarios
  def create_resource_substitutes(substitution)
    substitution['substitutes'].each do |substitute|
      @request = JSON.parse(@request.to_json.gsub(substitute, substitution['prefix'] + substitute))
      @response_expectation = JSON.parse(@response_expectation.to_json.gsub(substitute, substitution['prefix'] + substitute))
    end
  end

end
