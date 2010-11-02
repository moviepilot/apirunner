require 'chronic'

class Checker
  @@children = []

  def initialize(testcase, response, excludes=nil)
    @testcase = testcase
    @response = response
    @excludes = excludes
  end

  # executes the checking routine and returns a result object
  # to be overwritten in child classes
  def check
    result = Result.new(@testcase, @response)
  end

  # returns a list of symbolized plugin names
  def self.available_plugins
    return @@children.map{ |child| child.to_s }
  end

  private
  def get_time(time)
    one_day = 24 * 3600 # seconds
    if time.match(/^@next_occurence_of/)
      time = Chronic.parse( "next #{time.gsub(/^@next_occurence_of/, '')}" ) || Chronic.parse(time.gsub(/^@next_occurence_of/, ''))
      time -= one_day if time - Time.now > one_day
    else
      time = Chronic.parse( time.gsub(/^@/,'') )
    end

    Chronic.parse(time)
  end

  # tracks all children of this class
  # this way plugins can be loaded automagically
  def self.inherited(child)
    @@children << child
  end

  # returns true if given attributes is an excluded item that does not have to be evaluated in this environment
  def excluded?(item)
    @excludes.include?(item)
  end

  def is_time_check?(header, expectation)
    return false unless header and expectation 
    # only support time check for certain headers + custom X-* headers
    return false unless ["cache-control[max-age]", "cache-control[s-maxage]", "cache-control[min-fresh]", "retry-after", "last-modified"].include?(header.downcase) || header.downcase.match(/x-/)
    return false unless expectation.strip.match(/^@/)
    return true
  end


  def compare_time(header, expectation, value)
    return false unless is_time_check?(header, expectation)
    if ["cache-control[max-age]", "cache-control[s-maxage]", "cache-control[min-fresh]", "retry-after"].include?(header.downcase) || header.downcase.match(/x-/)
      diff = get_time(expectation) - Time.now - value.to_i
    elsif header.to_s.downcase == "last-modified"
      diff = get_time(expectation) - Chronic.parse(value)
    end
    
    diff >= -5 && diff <= 5
  end

  def is_number_comparison?(string)
    return false unless string
    string.match(/^[><]\s*\d+\s*$/) || string.match(/^[<>=]=\s*\d+\s*$/)
  end

  def compare_number(expectation, value)
    return false unless value && value.match(/[\d\.]+/)
    eval "#{value}#{expectation}"
  end

  # returns true if given string seems to be a regular expression
  def is_regex?(string)
    string.to_s.match(/^\/.+\/$/)
  end

  # returns true if the given regular expression matches the given value
  def regex_matches?(regex, value)
    regex = Regexp.compile( regex.gsub(/^\//, '').gsub(/\/$/,'') )
    !!value.to_s.match(regex)
  end

  # returns true if the given string exactly matches the given value
  def string_matches?(string, value)
    string.to_s == value.to_s
  end

  # parses output into JSON object
  def valid_json?(response_body)
    # responses may be nil, return true then
    return true if response_body.nil? or response_body == {} or response_body == "" or response_body == " "
    # returns true if given response is valid json, else false
    JSON.parse(response_body.to_s) rescue false
  end

end
