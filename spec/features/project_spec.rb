# encoding: utf-8
require_relative '../spec_helper'

describe 'Get Projects' do
  
  before(:all) do
    app.set :root, File.join(File.dirname(__FILE__), '../..')
    app.set :full_log_path, File.join(File.dirname(__FILE__), '../data/tmp/logs')
    app.set :full_projects_path, File.join(File.dirname(__FILE__), '../data/projects')
    app.set :full_build_path, File.join(File.dirname(__FILE__), '../data/tmp/www')
  end

  describe 'GET project configs' do
    it 'gets basic config' do
      project = Project.new(File.join(app.settings.full_projects_path, 'project_1'))
      expect(project.all_config_files.size).to eq 2
      
      config = project.config
      expect(config['title']).to eq 'Title'
    end
  end

  describe 'builds project' do
    it 'which is existent' do
      ProjectBuildProcessor.perform('project_1')

      # only proove if the files are available
      project_folder = File.join(app.settings.full_build_path, 'project_1')
      expect(File.directory?(File.join(project_folder, 'development'))).to be true
      expect(File.exist?(File.join(app.settings.full_build_path, 'project_1/development/index.html'))).to be true
      expect(File.exist?(File.join(app.settings.full_build_path, 'project_1/development/test.html'))).to be true

      # delete it afterwards
      FileUtils.rm_rf(project_folder)
      expect(File.directory?(project_folder)).to be false
    end
  end

end