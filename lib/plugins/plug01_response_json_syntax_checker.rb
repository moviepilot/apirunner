class ResponseJsonSyntaxChecker < Checker

  # checks if the given testcase body represents syntactically valid JSON
  def check
    result = Result.new(@testcase, @response)
    if not valid_json?(@response.body)
      result.succeeded = false
      result.error_message = "expected valid JSON in body\n got --#{@response.body[1..400]}-- #{@response.body.class}"
    end
    result
  end

end
