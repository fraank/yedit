# encoding: utf-8
require "rake"
require "sinatra"
require 'sinatra/extension'
require "sinatra/config_file"

require 'i18n'
require 'i18n/backend/fallbacks'

require "jekyll"

ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

config = YAML.load_file(File.join(File.dirname(__FILE__), '../config/config.yml'))

if ENV['RACK_ENV'] != "test"
  require 'resque'
  Resque.redis = Redis.new(:host => config['redis']['host'], :port => config['redis']['port'])
end

# empty resque for runtime
# Resque.remove_queue("...")
# Resque::Failure.clear

# include extension
Dir.glob( File.join(File.dirname(__FILE__), 'extensions/*.rb')).each { |r| require r.gsub('.rb', '') }

# include helpers
Dir.glob( File.join(File.dirname(__FILE__), 'helpers/*.rb')).each { |r| require r.gsub('.rb', '') }

# include models
Dir.glob( File.join(File.dirname(__FILE__), 'models/*.rb')).each { |r| require r.gsub('.rb', '') }

#include jobs
Dir.glob( File.join(File.dirname(__FILE__), 'jobs/*.rb')).each { |r| require r.gsub('.rb', '') }

# include controllers
Dir.glob( File.join(File.dirname(__FILE__), 'controllers/*.rb')).each { |r| require r.gsub('.rb', '') }