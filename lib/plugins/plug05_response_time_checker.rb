class ResponseTimeChecker < Checker

  # checks if the request response cycle exceeded the maximum expected time
  def check
    result = Result.new(@testcase, @response)
    begin
      if not (@testcase.response_expectation['runtime'].nil? || @response.runtime.to_f <= @testcase.response_expectation['runtime'].to_f)
        result.succeeded = false
        result.error_message = " expected request->response runtime was #{@testcase.response_expectation['runtime']}, real runtime was #{@response.runtime}"
      end
     rescue Exception => e
       result.succeeded = false
       result.error_message = " unexpected error while parsing testcase/response. Check your testcase format!"
       result.error_message = "\n\nException occured: #{e}"
     end
    result
  end

end
