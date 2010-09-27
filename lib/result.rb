class Result

  attr_accessor :succeeded
  attr_accessor :error_message

  def initialize(testcase, response)
    @succeeded = true
    @testcase = testcase
    @response = response
    @error_message = nil
  end

  def honk_in(verbosity="rspec", index)
    self.send(verbosity.to_sym, index)
  end

  def error_message
    @error_message
  end

  def rspec(index)
    if not @succeeded
      puts "\nError (#{index}) - \"#{@testcase['name']}\""
      puts @error_message
    end
  end

  def verbose_on_error
    "I am the on_error message"
  end

  def verbose_on_success
    "I am the on_success message"
  end

  def verbose_with_curl
    "I am a message including curl call parameters"
  end

end
