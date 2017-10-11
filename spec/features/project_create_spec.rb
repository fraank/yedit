# encoding: utf-8
require_relative '../spec_helper'

describe 'create project' do
  
  before(:all) do
    app.set :root, File.join(File.dirname(__FILE__), '../..')
    app.set :full_log_path, File.join(File.dirname(__FILE__), '../data/tmp/logs')
    app.set :full_projects_path, File.join(File.dirname(__FILE__), '../data/projects')
    app.set :full_build_path, File.join(File.dirname(__FILE__), '../data/tmp/www')
  end

  describe 'helper functions for creating projects' do

    it "should return all layouts with minimum default" do
      layouts_path = File.join(app.settings.root, 'jekyll/scaffolds/projects')
      layouts = Project.get_all_scaffold_layouts(layouts_path)

      expect(layouts).to include('default')
    end

  end

  describe 'create project' do
    
    it "should fail due to an invalid name" do
      project = Project.new(File.join(app.settings.full_projects_path, 'pröjekt_§$%'))
      created = project.create(File.join(app.settings.root, 'jekyll/scaffolds/projects'), 'default')

      expect(project.exists?).to be false
      expect(created).to be false
    end

    it "should fail because project already exists" do
      project = Project.new(File.join(app.settings.full_projects_path, 'project_1'))
      created = project.create(File.join(app.settings.root, 'jekyll/scaffolds/projects'), 'default')

      expect(project.exists?).to be true
      expect(created).to be false
    end    

    it "should succeed" do
      project = Project.new(File.join(app.settings.full_projects_path, 'project_create_1'))
      created = project.create(File.join(app.settings.root, 'jekyll/scaffolds/projects'), 'default')

      expect(project.exists?).to be true
      expect(created).to be true

      FileUtils.rm_rf(project.path)
    end

  end

end