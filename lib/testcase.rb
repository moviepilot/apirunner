class Testcase

  attr_reader :raw, :name, :request, :response_expectation

  def initialize(raw)
    @raw = raw
    @name = raw['name']
    @request = @raw['request']
    @response_expectation = @raw['response_expectation']
  end

end
