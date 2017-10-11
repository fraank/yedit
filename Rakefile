# encoding: utf-8
require 'rspec/core/rake_task'
require 'resque/tasks'
require File.join(File.dirname(__FILE__), 'app/bootstrap')

# include specs
# RSpec::Core::RakeTask.new :specs do |task|
#   task.pattern = Dir['spec/**/*_spec.rb']
# end

# task :default => ['specs']
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# define app for rake tasks and resque
def app
  ApplicationController.new
end

task "resque:setup" do
  ENV['QUEUE'] = '*'
end