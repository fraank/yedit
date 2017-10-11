# encoding: utf-8
require_relative '../spec_helper'

describe 'Get Projects' do
  
  before(:all) do
    app.set :full_log_path, File.join(File.dirname(__FILE__), '../data/tmp/logs')
    app.set :full_log_path, File.join(File.dirname(__FILE__), '../data/tmp/logs')
    app.set :full_projects_path, File.join(File.dirname(__FILE__), '../data/projects')
    app.set :full_build_path, File.join(File.dirname(__FILE__), '../data/tmp/www')
  end

  it "creates a single file" do
    project = Project.new(app.settings.full_projects_path+'/project_1')
    project_file = ProjectFile.new(project, 'test_unknown.txt')
    created = project_file.create

    expect(created).to be true
    expect(project_file.exists?).to be true

    deleted = project_file.delete
    expect(deleted).to be true
    expect(project_file.exists?).to be false 
  end

  it "creates and deletes a post in project" do
    project = Project.new(app.settings.full_projects_path+'/project_1')
    
    project_file = ProjectFile.new(project)
    created = project_file.create_post('This is a real cool post 11')

    expect(created).to be true
    expect(project_file.exists?).to be true

    project_file_new = ProjectFile.new(project)
    created_2 = project_file_new.create_post('This is a real cool post 11')
    expect(created_2).to be false

    expect(project_file.delete).to be true
    expect(project_file.exists?).to be false

    # delete _posts folder
    project_folder = ProjectFolder.new(project, '_posts')
    expect(project_folder.delete).to be true
  end  

end