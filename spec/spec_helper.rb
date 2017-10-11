# encoding: utf-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# spec/spec_helper.rb
ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), '../app/bootstrap')
require 'rspec'
require 'rack/test'

RSpec.configure do |config|
  include Rack::Test::Methods
  
  def app
    # include defined controller in app context
    if defined? @application_controller
      eval(@application_controller)
    else
      eval('Sinatra::Application')
    end
  end
  
end

module XhrHelpers
  def xhr(verb, path, params = {})
    send(verb, path, params, "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest")
  end
  alias_method :ajax, :xhr
end

RSpec.configuration.include XhrHelpers, :type => :controller