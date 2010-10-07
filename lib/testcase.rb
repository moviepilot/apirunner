class Testcase

  attr_reader :raw, :name, :request, :response_expectation, :wait_before_request

  def initialize(raw)
    @raw = raw
    @name = raw['name']
    @request = @raw['request']
    @response_expectation = @raw['response_expectation']
    @wait_before_request = @raw['wait_before_request'].nil? ? 0 : @raw['wait_before_request']
  end

end
