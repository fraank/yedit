require_relative '../spec_helper'

describe 'FilesController', :type => :controller do

  before(:context) do
    @application_controller = "FilesController"
  end

  before(:all) do
    app.set :full_projects_path, File.join(File.dirname(__FILE__), '../data/projects')
    app.set :root, File.join(File.dirname(__FILE__), '../..')
  end

  describe 'GET root /project_1/files' do
    before { get '/project_1/files' }

    it 'is successful' do
      expect(last_response.status).to eq 200
    end
  end

  describe 'get filetree of project' do
    before {
      xhr :get, '/project_2/files/tree'
    }

    xit 'should match project test-structure' do
      data = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      expect(data["success"]).to eq true
      testfolderstructure = {
        "name" => "subfolder",
        "children"=> [
          {
            "name" => "subsubfolder",
            "children" => [
              {
                "name" => "subsubsubfolder",
                "children" => [ 
                  {
                    "name" => "test.html"
                  }
                ]
              }
            ]
          }
        ]
      }
      expect(data["filetree"]["children"]).to include(testfolderstructure)
    end
  end

  describe 'file create file in existing folder' do
    before {
      xhr :post, '/project_1/files/create', file: {
        name: "testfile.md"
      }
    }

    it 'creates successful' do
      data = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      expect(data["success"]).to eq true
      
      deleted = File.delete(File.join(app.settings.full_projects_path, 'project_1/testfile.md'))
      expect(deleted).to eq 1
    end
  end

  describe 'folder create folder in existing folder' do
    before {
      xhr :post, '/project_1/files/create', folder: {
        name: "testfolder"
      }
    }

    it 'creates successful' do
      data = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      expect(data["success"]).to eq true
      
      deleted = FileUtils.rm_rf(File.join(app.settings.full_projects_path, 'project_1/testfolder'))
      expect(deleted.size).to eq 1
    end
  end

  describe 'file create file in existing folder' do
    before {
      xhr :post, '/project_1/files/create', file: {
        name: "testfile.md"
      }
    }

    it 'creates successful' do
      data = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      expect(data["success"]).to eq true
      
      deleted = File.delete(File.join(app.settings.full_projects_path, 'project_1/testfile.md'))
      expect(deleted).to eq 1
    end
  end

  describe 'save to a (new) file' do
    content = "This is the content of the file."
    file_name = "testfile.md"
    project_name = 'project_3'

    before { 
      xhr :post, '/project_3/files/save', file: {
        name: file_name,
        content: content
      }
    }

    it 'creates successful' do
      data = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      expect(data["success"]).to eq true

      read_content = File.read(File.join(app.settings.full_projects_path, File.join(project_name, file_name)), :encoding => "UTF-8").force_encoding("UTF-8")
      expect(read_content).to eq content
      deleted = File.delete(File.join(app.settings.full_projects_path, File.join(project_name, file_name) ))
      expect(deleted).to eq 1
    end
  end

  describe 'edit file' do
    file_name = "test_content.md"

    before { 
      xhr :post, '/project_1/files/edit', file: {
        name: file_name
      }
    }

    it 'get content' do
      data = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      expect(data["success"]).to eq true

      expect(data["content"]).to eq "test"
    end
  end

  # describe 'delete file' do
  #   project_name = 'project_3'
  #   file_name = "testfile_delete.md"
  #   file = File.join(app.settings.full_projects_path, File.join(project_name, file_name))

  #   before do
  #     xhr :post, '/'+project_name+'/files/create', file: {
  #       name: file_name
  #     }
  #     xhr :post, '/'+project_name+'/files/delete', file: {
  #       name: file_name
  #     }
  #   end

  #   it 'should not be available' do
  #     data = JSON.parse(last_response.body)
  #     expect(last_response.status).to eq 200
  #     expect(data["success"]).to eq true
  #     expect(File.exist?(file)).to eq false

  #   end
  # end
  
end