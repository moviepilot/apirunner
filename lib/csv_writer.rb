class CsvWriter
  require 'csv'

  def initialize(file)
    @file = file
  end

  def write(method, data)
    self.send(method.to_sym, sort(data))
  end

  protected

  # appends given data to an existing CSV file
  def append(data)
    data = existant_data
    STDERR.puts("appending #{data} to file #{@file}")
  end

  # recreates the CSV file and writes the data to it
  def create(data)
    STDERR.puts("creating #{data} to file #{@file}")
  end

  # does not write any data ... for convenience only
  def none(data)
    STDERR.puts("doing nothing wit CSV")
    return
  end

  # returns the CSV's headers so that every appended line can be sorted and
  # matched testcase by testcase even if new testcases occure.
  def header
    begin
      CSV.foreach(@file) do |row|
        return row
      end
    rescue
      return nil
    end
  end

  # sorts the given array of testcases by the existing headers
  # new testcases are appended at the right end of the csv file
  # so the CSV stays consistent even if the number of testcases changes
  def sort(data)
    return data
  end

  # parses older data from already existing CSV File and returns them
  # if no file exists yet or no data is in, it returns an empty array
  def existant_data
    data = []
    begin
      CSV.foreach(@file) do |row|
        data << row
      end
      return data
    rescue
      return data
    end
  end

end






