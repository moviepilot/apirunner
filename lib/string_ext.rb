class String
  # generates filenames from classnames the rails way
  def underscore
    self.to_s.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
  end

  # opposites underscore defined above
  def camelize(first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      self.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    else
      self.first + camelize(lower_case_and_underscored_word)[1..-1]
    end
  end
  # # opposites underscore defined above
  # def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
  #   if first_letter_in_uppercase
  #     lower_case_and_underscored_word.to_s.gsub(/\\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
  #   else
  #     lower_case_and_underscored_word.first + camelize(lower_case_and_underscored_word)[1..-1]
  #   end
  # end
end
