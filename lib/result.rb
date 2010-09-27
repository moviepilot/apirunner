class Result

  attr_accessor :succeeded
  attr_accessor :error_message

  def initialize(testcase, response)
    @succeeded = true
    @testcase = testcase
    @response = response
    @error_message = nil
  end

  def error_message
    @error_message
  end

end
