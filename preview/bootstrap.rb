# encoding: utf-8

require "rake"
require "sinatra"
require 'sinatra/extension'
require "sinatra/config_file"

ENV['RACK_ENV'] ||= 'development'

# send to config.ru -> todo delete
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# include controllers
require File.join(File.dirname(__FILE__),'controllers/application_controller'.gsub('.rb', ''))