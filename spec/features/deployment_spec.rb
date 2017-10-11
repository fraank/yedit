# encoding: utf-8
require_relative '../spec_helper'

describe 'deployment for aws' do

  before(:all) do
    app.set :full_log_path, File.join(File.dirname(__FILE__), '../data/tmp/logs')
    app.set :full_projects_path, File.join(File.dirname(__FILE__), '../data/projects')
  end
  
  describe 'receive deployment configs' do
    
    before(:all) do
      project = Project.new(File.join(app.settings.full_projects_path, 'project_1'))
      @deployment = Deployment.new(project)
    end

    it 'get config files' do
      deployment_files_1 = @deployment.config_files()
      expect(deployment_files_1.size).to eq 2
    end

    it 'get merged config content' do
      deployment_config_1 = @deployment.config()

      expect(deployment_config_1['aws']['s3_bucket']).to eq 'testing-def'
    end

  end

  describe 'check mime-types' do
    
    before(:all) do
      project = Project.new(File.join(app.settings.full_projects_path, 'project_1'))
      @deployment = Deployment.new(project)
    end

    it 'get merged config content' do
      mime_type = @deployment.get_mime_type("file.txt")
      expect(mime_type).to eq "text/plain"

      mime_type = @deployment.get_mime_type("file.txxt")
      expect(mime_type).to eq false
    end
   
  end

end