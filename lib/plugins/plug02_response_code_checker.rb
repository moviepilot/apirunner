class ResponseCodeChecker < Checker

  # checks the given responses status code against the one in the expectation and returns result object
  def check
    result = Result.new(@testcase, @response)
    begin
      if not @testcase.response_expectation['status_code'].to_s == @response.code.to_s
        result.succeeded = false
        result.error_message = " expected response code --#{@testcase.response_expectation['status_code']}--\n got response code --#{@response.code}--"
      end
     rescue Exception => e
       result.succeeded = false
       result.error_message = " unexpected error while parsing testcase/response. Check your testcase format!"
       result.error_message = "\n\n Exception occured: #{e}"
     end
    result
  end

end
