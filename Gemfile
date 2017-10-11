source 'http://rubygems.org'

gem 'rake'

gem 'sinatra'
gem 'sinatra-contrib', require: false
gem 'i18n'

# some basic testing
group :test, :development do
  gem 'rspec'
  gem 'thin'
  gem 'rack-test'
  gem 'yard'
end

# we want to use haml
gem 'haml', '~> 4'
gem 'jekyll', '~> 3'

# executing and sheduling tasks
gem 'resque'

# for deployment to s3 / cloudfront
gem 'aws-sdk', '~> 2'

# for running multiple applications and processes
gem 'foreman'

# dynamic loading of plugins and themes, run 'bundle install' after you added something new
# please consider placing here only theme-gems which have no dependencies other than main project
config_file = File.join(File.dirname(__FILE__), 'config/config.yml')
if File.exists?(config_file)
  require 'yaml'
  config = YAML.load_file(File.join(File.dirname(__FILE__), 'config/config.yml'))

  require File.join(File.dirname(__FILE__), 'app/models/theme.rb')
  require File.join(File.dirname(__FILE__), 'app/models/plugin.rb')

  if config['themes_path'] && config['themes_path'] != ""
    plugins = Theme.all(File.join(File.dirname(__FILE__), config['themes_path']))
    plugins.each do |plugin|
      dir_name = plugin[:path]
      gem_name = plugin[:name]
      # p "loaded plugin: #{gem_name}"
      gem gem_name, :path => dir_name, :require => false
    end
  end

  if config['plugins_path'] && config['plugins_path'] != ""
    themes = Theme.all(File.join(File.dirname(__FILE__), config['plugins_path']))
    themes.each do |theme|
      dir_name = theme[:path]
      gem_name = theme[:name]
      # p "loaded theme: #{gem_name}"
      gem gem_name, :path => dir_name, :require => false
    end
  end
end