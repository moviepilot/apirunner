class ResponseHeaderChecker < Checker

  # checks given header against the given expepctation and returns a result object
  def check
    result = Result.new(@testcase, @response)
    begin
      @testcase.response_expectation['headers'].each_pair do |header_name, header_value|
        header_name = header_name.downcase
        if is_regex?(header_value)
          if not (excluded?(header_name) or regex_matches?(header_value, @response.headers[header_name]))
            result.succeeded = false
            result.error_message = " expected header identifier --#{header_name}-- to match regex --#{header_value}--\n got --#{@response.headers[header_name]}--"
          end
        elsif is_time_check?(header_name, header_value)
          if not (excluded?(header_name) or compare_time(header_name, header_value, @response.headers[header_name]))
            result.succeeded = false
            result.error_message = " expected header identifier --#{header_name}-- to match time (+/- 5 seconds) --#{header_value} / #{Chronic.parse(header_value.tr('@',''))}--\n got --#{@response.headers[header_name]}--"
          end
        elsif is_number_comparison?(header_value)
          if not (excluded?(header_name) or compare_number(header_value, @response.headers[header_name]))
            result.succeeded = false
            result.error_message = " expected header identifier --#{header_name}-- to match number comparison --#{header_value}--\n got --#{@response.headers[header_name]}--"
          end
        else
          if not (excluded?(header_name) or string_matches?(header_value, @response.headers[header_name]))
            result.succeeded = false
            result.error_message = " expected header identifier --#{header_name}-- to match --#{header_value}--\n got --#{@response.headers[header_name]}--"
          end
        end
      end unless (@testcase.response_expectation['headers'].nil? or @testcase.response_expectation['headers'].empty?)
     rescue Exception => e
       result.succeeded = false
       result.error_message = " unexpected error while parsing testcase/response. Check your testcase format!"
       result.error_message = "\n\nException occured: #{e}"
     end
    result
  end

end
