# encoding: utf-8
require_relative '../spec_helper'

describe 'Get Projects' do
  
  before(:all) do
    app.set :full_log_path, File.join(File.dirname(__FILE__), '../data/tmp/logs')
    app.set :full_log_path, File.join(File.dirname(__FILE__), '../data/tmp/logs')
    app.set :full_projects_path, File.join(File.dirname(__FILE__), '../data/projects')
    app.set :full_build_path, File.join(File.dirname(__FILE__), '../data/tmp/www')
  end

end