# encoding: utf-8
require_relative '../spec_helper'

describe 'project model behaviour' do
  
  before(:all) do
    app.set :root, File.join(File.dirname(__FILE__), '../..')
    app.set :full_log_path, File.join(File.dirname(__FILE__), '../data/tmp/logs')
    app.set :full_projects_path, File.join(File.dirname(__FILE__), '../data/projects')
    app.set :full_build_path, File.join(File.dirname(__FILE__), '../data/tmp/www')
  end

  describe 'file list functionality' do

    it 'shows all files (without posts) in project' do
      project = Project.new(app.settings.full_projects_path+'/project_1')
      files = project.file_list

      # default root object
      file_name = 'index.html'
      file_path = File.join(File.dirname(__FILE__), '../data/projects/project_1/'+file_name)
      expect(files).to include(name: file_name, path: file_path)

      # nested object
      file_name = 'new_file.html'
      file_path = File.join(File.dirname(__FILE__), '../data/projects/project_1/sync_folder2/new_folder/'+file_name)
      expect(files).to include(name: file_name, path: file_path)
    end

    it 'shows all posts in project' do  
      project = Project.new(app.settings.full_projects_path+'/project_3')
      posts = project.last_posts(5)

      file_name = '2017-10-09-welcome.md'
      file_path = File.join(File.dirname(__FILE__), '../data/projects/project_3/_posts/'+file_name)
         
      expect(posts).to include(name: file_name, path: file_path)

      file_name = '2017-10-10-tag.md'
      file_path = File.join(File.dirname(__FILE__), '../data/projects/project_3/_posts/tag/'+file_name)
         
      expect(posts).to include(name: file_name, path: file_path)
    end

    it 'the correct number of files for project' do  
      project = Project.new(app.settings.full_projects_path+'/project_3')
      posts = project.last_posts(1)
      expect(posts.size).to eq 1
    end

    it 'should not throw an error it _posts does nox exists in project' do  
      project = Project.new(app.settings.full_projects_path+'/project_1')
      posts = project.last_posts(5)
      expect(posts.size).to eq 0
    end

  end

end