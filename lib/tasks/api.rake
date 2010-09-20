config = YAML.load_file("#{Rails.root}/vendor/plugins/telekom_api/config/api_runner.yaml")

namespace :api do
  namespace :runner do
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
end
