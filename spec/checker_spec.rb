require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'json'
require 'nokogiri'

describe "Checker" do
  describe "self.available_plugins" do
    it "should return an array of available plugins inheriting from self" do
      Checker.available_plugins.should be_a(Array)
      Checker.available_plugins.size.should_not == 0
    end
  end
  describe "excluded?" do
    it "should return true if a given item is not part of the instances exludes" do
      c = Checker.new({}, {}, ["exclude_1", "exclude_2"])
      c.send(:excluded?, "exclude_1").should be_true
      c.send(:excluded?, "exclude_2").should be_true
    end
    it "should return false if a given item is part of the instances excludes" do
      c = Checker.new({}, {}, ["exclude_1", "exclude_2"])
      c.send(:excluded?, "no_exclude").should be_false
    end
  end
  describe "is_regex?" do
    it 'should return true if the given string seems to be a regular expression' do
      string = "/^\d{3}$/"
      Checker.new({},{}).send(:is_regex?, string).should be_true
    end
    it 'should return false if the given string does not seem to be a regular expression' do
      string = "fooz"
      Checker.new({},{}).send(:is_regex?, string).should be_false
      string = "/fooz"
      Checker.new({},{}).send(:is_regex?, string).should be_false
      string = "fooz/"
      Checker.new({},{}).send(:is_regex?, string).should be_false
    end
  end

  describe "is_number_comparison?" do
    it "should return true when expectation starts with <=, >=, >,<, ==" do
      [">", ">=", "<", "<=", "=="].each do |comp|
        string = "#{comp}4"
        Checker.new({}, {}).send(:is_number_comparison?, string).should be_true
        string = "#{comp} 4"
        Checker.new({}, {}).send(:is_number_comparison?, string).should be_true
        string = "#{comp} 4                                                           "
        Checker.new({}, {}).send(:is_number_comparison?, string).should be_true
      end
    end

    it "should return false when expectation does not start with >,<, =" do
      [">", ">=", "<", "<=", "=="].each do |comp|
        string = "#{comp}hallo"
        Checker.new({}, {}).send(:is_number_comparison?, string).should be_false
        string = "#{comp} hallo"
        Checker.new({}, {}).send(:is_number_comparison?, string).should be_false
        string = "#{comp}"
        Checker.new({}, {}).send(:is_number_comparison?, string).should be_false
        string = "#{comp} 4 hihihihihihi"
        Checker.new({}, {}).send(:is_number_comparison?, string).should be_false
      end

      string = "/hallo/"
      Checker.new({}, {}).send(:is_number_comparison?, string).should be_false
      string = "hallo"
      Checker.new({}, {}).send(:is_number_comparison?, string).should be_false
      string = ""
      Checker.new({}, {}).send(:is_number_comparison?, string).should be_false
      string = nil
      Checker.new({}, {}).send(:is_number_comparison?, string).should be_false
    end

  end

  describe "time_check" do
    it "should perform a time check for max-age, s-maxage, min-fresh, retry-after, last-modified and X-* headers when expectation starts with @" do
      ["cache-control[max-age]", "cache-control[s-maxage]", "cache-control[min-fresh]", "retry-after", "Last-Modified", "X-My-Custom-Timestamp"].each do |header|
        Checker.new({}, {}).send(:is_time_check?, header, "@tomorrow 4:00am").should be_true
      end
    end

    it "should not perform a time check for a header different to max-age, s-maxage, min-fresh, retry-after or X-* headers" do
      %w{Server Content-Type Content-Length Via Connection}.each do |header|
        Checker.new({}, {}).send(:is_time_check?, header, "@tomorrow 4:00am").should be_false
      end
    end

    it "should not perform a time check for if header or expectations or both are nil" do
      Checker.new({}, {}).send(:is_time_check?, nil, "@tomorrow 4:00am").should be_false
      Checker.new({}, {}).send(:is_time_check?, "cache-control[max-age]", nil).should be_false
      Checker.new({}, {}).send(:is_time_check?, nil, nil).should be_false
    end

    it "should correctly interpret @next_occurence_of " do
      one_hour = 3600 # seconds
      current_time =  Chronic.parse("today #{Time.now.hour}:00")
      three_hours_ago = current_time - 3*one_hour
      in_three_hours  = current_time + 3*one_hour

      Checker.new({}, {}).send(:get_time, "@next_occurence_of #{three_hours_ago.hour}:00").should == three_hours_ago + 24 * one_hour
      Checker.new({}, {}).send(:get_time, "@next_occurence_of #{in_three_hours.hour}:00").should  == in_three_hours
    end

    it "should correctly compare delta-seconds for headers  max-age, s-maxage, min-fresh, retry-after" do
      in_five_hours = Chronic.parse("in 5 hours")
      ["cache-control[max-age]", "cache-control[s-maxage]", "cache-control[min-fresh]", "retry-after", "X-My-Custom-Timestamp"].each do |header|
        Checker.new({}, {}).send(:compare_time, header, "@next_occurence_of #{in_five_hours}", 5 * 3600).should be_true
      end
    end

    it "should correctly transform an absolute time check to date for headers Last-Modified" do
      in_five_hours = Chronic.parse("in 5 hours")
      Checker.new({}, {}).send(:compare_time, "Last-Modified", "@#{in_five_hours}", in_five_hours.to_s).should be_true
    end

    def in_five_hours
      Chronic.parse("in 5 hours")
    end

    it "should compare with +/- 5 seconds tolarance" do
      #in_five_hours = Chronic.parse("in 5 hours")
      (-4..4).each do |diff|
        Checker.new({}, {}).send(:compare_time, "Last-Modified", "@#{in_five_hours}", Chronic.parse( (in_five_hours + diff) ).to_s).should be_true
        ["cache-control[max-age]", "cache-control[s-maxage]", "cache-control[min-fresh]", "retry-after", "X-My-Custom-Timestamp"].each do |header|
          Checker.new({}, {}).send(:compare_time, header, "@next_occurence_of #{in_five_hours}", 5 * 3600 + diff).should be_true
        end
      end

      [-6,6].each do |diff|
        Checker.new({}, {}).send(:compare_time, "Last-Modified", "@#{in_five_hours}", Chronic.parse( (in_five_hours + diff) ).to_s).should be_false
        Checker.new({}, {}).send(:compare_time, "Last-Modified", "@next_occurence_of #{in_five_hours}", 5 * 3600 + diff).should be_false
      end
    end
  end

  describe "compare_number" do
    it "should compare lt and lte correctly" do
      Checker.new({}, {}).send(:compare_number, "<4", "5").should be_false
      Checker.new({}, {}).send(:compare_number, "< 4", "5").should be_false

      Checker.new({}, {}).send(:compare_number, "< 4", "3").should be_true
      Checker.new({}, {}).send(:compare_number, "<4", "3").should be_true

      Checker.new({}, {}).send(:compare_number, "<=4", "4").should be_true
      Checker.new({}, {}).send(:compare_number, "<= 4", "4").should be_true
      Checker.new({}, {}).send(:compare_number, "<=4", "5").should be_false
      Checker.new({}, {}).send(:compare_number, "<= 4", "5").should be_false
      Checker.new({}, {}).send(:compare_number, "<=4", "3").should be_true
      Checker.new({}, {}).send(:compare_number, "<= 4", "3").should be_true
    end

    it "should compare gt and gte correctly" do
      Checker.new({}, {}).send(:compare_number, ">4", "5").should be_true
      Checker.new({}, {}).send(:compare_number, "> 4", "5").should be_true

      Checker.new({}, {}).send(:compare_number, "> 4", "3").should be_false
      Checker.new({}, {}).send(:compare_number, ">4", "3").should be_false

      Checker.new({}, {}).send(:compare_number, ">=4", "4").should be_true
      Checker.new({}, {}).send(:compare_number, ">= 4", "4").should be_true
      Checker.new({}, {}).send(:compare_number, ">=4", "5").should be_true
      Checker.new({}, {}).send(:compare_number, ">= 4", "5").should be_true
      Checker.new({}, {}).send(:compare_number, ">=4", "3").should be_false
      Checker.new({}, {}).send(:compare_number, ">= 4", "3").should be_false
    end

    it "should compare ==" do
      Checker.new({}, {}).send(:compare_number, "==4", "5").should be_false
      Checker.new({}, {}).send(:compare_number, "== 4", "5").should be_false

      Checker.new({}, {}).send(:compare_number, "==4", "4").should be_true
      Checker.new({}, {}).send(:compare_number, "==4", "4").should be_true
    end

    it "should return false when it gets unexpected header values" do
      Checker.new({}, {}).send(:compare_number, "==4", nil).should be_false
      Checker.new({}, {}).send(:compare_number, "== 4", "Exception").should be_false
      Checker.new({}, {}).send(:compare_number, "== 4", "q").should be_false
    end

  end

  describe "regex_matches?" do
    it 'should return true if the given regular expression matches the given value' do
      regex = "^\\d{2}$"
      value = "12"
      Checker.new({},{}).send(:regex_matches?, regex, value).should be_true
    end
    it 'should return false if the giveb reular expression does not match the given value' do
      regex = "^\\d{2}$"
      value = "123"
      Checker.new({},{}).send(:regex_matches?, regex, value).should be_false
      value = "foo"
      Checker.new({},{}).send(:regex_matches?, regex, value).should be_false
    end
  end
  describe "string_matches?" do
    it 'should return true if the given string matches the given value' do
      string = "bar"
      value = "bar"
      Checker.new({},{}).send(:string_matches?, string, value).should be_true
    end
    it 'should return false if the given string does not match the given value' do
      string = "bar"
      value = "foo"
      Checker.new({},{}).send(:string_matches?, string, value).should be_false
    end
  end
  describe "valid_json?" do
    it 'should return true if the given response body consists of valid JSON' do
      validateable = { :foo => "bar" }.to_json
      Checker.new({},{}).send(:valid_json?, validateable).should be_true
    end
    it 'should return true if the given response body is nil' do
      Checker.new({},{}).send(:valid_json?, nil).should be_true
    end
    it 'should return false if the given response body consists of anything else but valid JSON' do
      Checker.new({},{}).send(:valid_json?, "foobar").should be_false
    end
  end
end

