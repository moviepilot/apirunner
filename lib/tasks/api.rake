config = YAML.load_file("#{Rails.root}/vendor/plugins/telekom_api/config/api_runner.yaml")

namespace :api do
  namespace :run do
    config.each_key do |env|
      desc "runs a series of nessecary api calls and parses their response in environment #{env}"
      task env.to_sym => :environment do
        puts "Running API tests in environment #{env}"
        api_runner = ApiRunner.new(env)
        api_runner.run
        puts "\nTestrun finished\n\n"
      end
    end
  end
  desc "generates configuration and a skeleton for apirunner tests as well as excludes"
  task :scaffold do
    FileUtils.mkdir_p( "test/api_runner" )
    FileUtils.mkdir_p( "config" )
    FileUtils.cp_r( "#{APIRUNNER_ROOT}/examples/config", ".")
    FileUtils.cp_r( "#{APIRUNNER_ROOT}/examples/test", ".")
    puts "created the following files:"
    Dir.glob("#{APIRUNNER_ROOT}/examples/**/*").each do |file|
      puts "\t#{file.gsub(/.*examples\//, '')}"
    end
  end
end
