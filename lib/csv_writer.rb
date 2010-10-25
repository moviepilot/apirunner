class CsvWriter
  require 'csv'

  def initialize(path, env)
    @file = qualified_csv_path(path, env)
  end

  # dispatches the configured CSV create style to the matching method
  def write(method, data)
    self.send(method.to_sym, convert_to_hash_array(data))
  end

  protected

  def qualified_csv_path(path, env)
    return path + "/" + "api_performance_report_#{env}.csv"
  end

  # appends given data to an existing CSV file
  # if new testcases come in, their data is appended to the right of the csv
  # if one or more testcases are missing but were known before, the structure stays clean
  # and empty entries are made for these cases
  # to be refactored!
  def append(data)
    STDERR.puts("appending #{data} to file #{@file}")
    begin
      old_data = CSV.read(@file, headers: true, header_converters: :symbol)

      # delete_if deletes in referenced object too, therefore I need to clone data by hand
      data_copy = Array.new
      data.each do |value|
        data_copy << value
      end
      # isolate new results that need a new column to be appended to the right
      old_data.headers.each do |header|
        data_copy.delete_if{ |field| field[:identifier] == header.to_s }
      end

      # convert old data to array
      old_data_array = old_data.to_a

      # create a new header for every unknown result identifier
      data_copy.each do |result|
        old_data_array[0]  << result[:identifier]
      end unless data_copy.empty?

      # create the new line column by column in the right order
      line = []
      old_data_array[0].each do |header|
        debugger
        begin
          line << data.detect{ |field| field[:identifier] == header.to_s }[:runtime]
        rescue
          line << nil
        end
      end unless old_data_array[0].empty?

      # append the new line of data to existing data
      old_data_array << line

      # write the CSV
      file = File.open(@file, "w")
      CSV(file, col_sep: ",") do |csv|
        old_data_array.each do |line|
          csv << line
        end
      end
      file.close
    rescue
      create(data)
    end
  end

  # recreates the CSV file and writes the data to it
  def create(data)
    file = File.open(@file, "w")
    CSV(file, col_sep: ",") do |csv|
      csv << data.map{ |test| test[:identifier] }
      csv << data.map{ |test| test[:runtime] }
    end
    file.close
  end

  # does not write any data ... for convenience only
  def none(data)
  end

  # converts array of testcases into array of hashes containing only identifier and runtime of the testcases
  def convert_to_hash_array(data)
    hash_array = []
    data.each do |result|
      hash_array << { :identifier => result.testcase.unique_identifier, :runtime => result.response.runtime.round(3) }
    end
    return hash_array
  end

end
