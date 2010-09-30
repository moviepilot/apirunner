class Testcase

  attr_reader :raw, :request, :response_expectation

  def initialize(raw)
    @raw = raw
    @request = @raw['request']
    @response_expectation = @raw['response_expectation']
  end

end
