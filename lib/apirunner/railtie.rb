require 'apirunner'
require 'rails'

module Apirunner
  class Railtie < Rails::Railtie

    rake_tasks do
      load "tasks/api.rake"
    end
  end
end
