# encoding: utf-8
require_relative '../spec_helper'

describe 'HomeController', :type => :controller do
  
  before(:context) do
    @application_controller = "HomeController"
  end

  describe 'GET /' do
    before { get '/' }

    it 'is successful' do
      expect(last_response.status).to eq 200
    end
  end

end