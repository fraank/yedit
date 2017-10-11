# encoding: utf-8
require_relative '../spec_helper'

describe 'Test aws deployment' do

  before(:all) do
    app.set :full_log_path, File.join(File.dirname(__FILE__), '../data/tmp/logs')
    app.set :full_projects_path, File.join(File.dirname(__FILE__), '../data/projects')
    app.set :full_build_path, File.join(File.dirname(__FILE__), '../data/tmp/build_test')
  end
  
  describe 'receive deployment configs' do
    
    it 'syncs one file' do
      project = Project.new(File.join(app.settings.full_projects_path, 'project_1'))
      sync_file = 'sync_folder1/index.html'
      deployment = Deployment::Aws.new(project)

      # upload
      upload_succ = deployment.file_sync(File.join(project.path, sync_file), sync_file)
      expect(upload_succ).to eq true
      expect(deployment.get_created().size).to eq 1
      expect(deployment.get_updated().size).to eq 0

      # double upload the same file
      upload_succ = deployment.file_sync(File.join(project.path, sync_file), sync_file)
      expect(upload_succ).to eq true
      expect(deployment.get_ignored().size).to eq 1
      
      # delete
      delete_succ = deployment.file_delete(sync_file)
      expect(delete_succ).to eq true
      expect(deployment.get_deleted().size).to eq 1

      # p "requests made for syncing one file:"+deployment.get_request_count().to_s
    end


    it 'sets mimetypes correct' do
      project = Project.new(File.join(app.settings.full_projects_path, 'project_1'))
      
      sync_file = 'mime_types/stylesheet.css'
      deployment = Deployment::Aws.new(project)

      # p deployment.get_local_file_header(File.join(project.path, sync_file))
      upload_succ = deployment.file_sync(File.join(project.path, sync_file), sync_file)
      expect(upload_succ).to eq true

      data = deployment.get_remote_file(sync_file)
      #p data
      #p data.header
      #p data.header[:content_type]
      delete_succ = deployment.file_delete(sync_file)
      expect(delete_succ).to eq true


      sync_file = 'mime_types/kiwi.svg'
      deployment = Deployment::Aws.new(project)

      # p deployment.get_local_file_header(File.join(project.path, sync_file))
      upload_succ = deployment.file_sync(File.join(project.path, sync_file), sync_file)
      expect(upload_succ).to eq true

      data = deployment.get_remote_file(sync_file)
      # p data
      #p data.header
      #p data.header[:content_type]
      delete_succ = deployment.file_delete(sync_file)
      expect(delete_succ).to eq true
    end

    it 'syncs one folder' do
      project = Project.new(File.join(app.settings.full_projects_path, 'project_1'))

      deployment = Deployment::Aws.new(project)
      deployment.delete_all_files()

      # now upload old files
      deployment.folder_sync(File.join(project.path, 'sync_folder1'))
      remote_files = deployment.remote_files_all()

      local_files = deployment.get_files_local(File.join(project.path, 'sync_folder1'))

      expect(deployment.get_created().size).to eq local_files.size
      expect(remote_files.size).to eq local_files.size

      # do really testing
      deployment = Deployment::Aws.new(project)
      deployment.folder_sync(File.join(project.path, 'sync_folder2'))
      
      local_files = deployment.get_files_local(File.join(project.path, 'sync_folder2'))
      remote_files = deployment.remote_files_all('sync_folder2')
      expect(local_files.size).to eq remote_files.size

      # p "requests made for syncing one folder:"+deployment.get_request_count().to_s
    end

    it 'syncs one project' do
      project = Project.new(File.join(app.settings.full_projects_path, 'project_1'))
      
      # delete
      deployment = Deployment::Aws.new(project)
      deployment.delete_all_files()
      
      # deploy
      deployment = Deployment.new(project)
      deployments = deployment.deploy(app.settings.full_build_path)
      deployments.each do |cur_deployment|
        # p "requests made for syncing project:"+cur_deployment.get_request_count().to_s
      end
      expect(deployments.size).to eq 1
    end

    it 'sync cloudfront of project' do
      project = Project.new(File.join(app.settings.full_projects_path, 'project_1'))
      
      # delete
      deployment = Deployment::Aws.new(project)
      deployment.delete_all_files()
      
      # deploy
      deployment = Deployment.new(project)
      deployments = deployment.deploy(app.settings.full_build_path)
      deployments.each do |cur_deployment|
        cur_deployment.invalidate
        # p "requests made for syncing project:"+cur_deployment.get_request_count().to_s
      end
    end
  end

end