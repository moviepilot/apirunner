class Result

  attr_accessor :succeeded
  attr_accessor :error_message

  def initialize(testcase, response)
    @succeeded = true
    @testcase = testcase
    @response = response
    @error_message = nil
  end

  # honk out the errors message corresponding to the verbosity configuration the user took
  def honk_in(verbosity="rspec", index)
    self.send(verbosity.to_sym, index)
  end

  private

  # yields out rspec like error messages only in case of an error
  def rspec(index)
    if not @succeeded
      puts "\n#{color_print("Error", :red)} (#{index}) - \"#{@testcase.name}\""
      puts @error_message
    end
  end

  # yields a more verbose error message only in case of an error
  def verbose_on_error(index)
    be_verbose(index) if not @succeeded
  end

  # yields a more verbose message in case of an error AND success
  def verbose_on_success(index)
    be_verbose(index)
  end

  # yields a more verbose message in any case and includes a curl command to manually simulate the testcase
  def verbose_with_curl(index)
    be_verbose(index)
    puts "\n  simulate this call with: \"curl TODO\""
  end

  # yields the verbose error messages
  def be_verbose(index)
    puts "\n#{result_case} (#{index+1})- \"#{@testcase.name}\""
    puts @error_message
    puts("  More more more verbosity\n")
    puts("  request method: #{@testcase.request['method']}")
    puts("  resource path: #{@testcase.request['path']}")
    puts("  request headers: #{@testcase.request['headers']}")
    puts("  JSON body sent: #{@testcase.request['body']}")
    puts("  expectation:")
    puts("    response status code: #{@testcase.response_expectation['status_code']}")
    puts("    response headers: #{@testcase.response_expectation['headers']}")
    puts("    response body: #{@testcase.response_expectation['body']}")
    puts("  result:")
    puts("    response status code: #{@response.code}")
    puts("    response headers: #{@response.headers}")
    puts("    response body: #{JSON.parse(@response.body) rescue nil}")
  end

  # returns the result case for interpolation in the output message header
  def result_case
    if @succeeded
      color_print("Success", :green)
    else
      color_print("Error", :red)
    end
  end

  def color_print(message, color)
    case ENV['FORMAT']
      when 'html'  then "<span style='color:#{color}'>#{message}</span>"
      when 'plain' then message
      else
        prefix, suffix = ansi_colors(color)
        "#{prefix}#{message}#{suffix}"
      end
    end
  end

  def ansi_colors(color)
    case color
      when 'green' then ['\033[32m', '\033[0m']
      when 'red'   then ['\033[31m', '\033[0m']
      else ['','']
    end
  end

end
