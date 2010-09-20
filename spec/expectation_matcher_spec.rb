require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'ExpectationMatcher' do
  describe 'regex_matches?' do
    it 'should return true if given regex matches the given string' do
      ExpectationMatcher.new.send(:regex_matches?, "/^\\d{2}$/", "12").should be_true
    end
    it 'should return false if the given regex does not match the given string' do
      ExpectationMatcher.new.send(:regex_matches?, "/^\\d{2}$/", "133").should be_false
    end
  end
end

