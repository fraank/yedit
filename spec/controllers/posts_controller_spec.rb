require_relative '../spec_helper'

describe 'PostsController', :type => :controller do

  before(:context) do
    @application_controller = "PostsController"
  end

  before(:all) do
    app.set :full_projects_path, File.join(File.dirname(__FILE__), '../data/projects')
    app.set :root, File.join(File.dirname(__FILE__), '../..')
  end

  describe 'GET root /project_1/posts' do
    before { get '/project_1/posts' }

    it 'is successful' do
      expect(last_response.status).to eq 200
    end
  end

  describe 'get tree of posts' do
    before {
      xhr :get, '/project_1/posts/tree'
    }

    xit 'should match project test-structure' do
      data = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      expect(data["success"]).to eq true
      testfolderstructure = {"name" => "Posts", "children" => [
          {
            "name" => "2016-11-21-test1.md",
          },
          {
            "name" => "category1",
            "children"=> [
              {
                "name" => "2016-11-21-test2.md"
              },
              {
                "name" => "2016-11-30-empty-file.md"
              }
            ]
          }
        ]
      }
      expect(data["tree"]).to eq testfolderstructure
    end
  end

  describe 'post create post in rootfolder' do
    before {
      xhr :post, '/project_1/posts/create', post: {
        name: "this is my new post"
      }
    }

    it 'creates successful' do
      data = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200

      expect(data["name"].include?('this-is-my-new-post')).to eq true
      expect(data["name"].include?('.md')).to eq true

      expect(data["success"]).to eq true

      deleted = File.delete(File.join(app.settings.full_projects_path, File.join('project_1/_posts', data["name"])))
      expect(deleted).to eq 1
    end
  end

  describe 'post create post in subfolder' do
    before {
      xhr :post, '/project_1/posts/create', post: {
        name: "/folder1/this is my new post"
      }
    }

    it 'creates successful' do
      data = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200

      expect(data["path"].start_with?('folder1/')).to eq true

      expect(data["name"].include?('this-is-my-new-post')).to eq true
      expect(data["name"].include?('.md')).to eq true

      expect(data["success"]).to eq true
      
      # delete recursive folder
      deleted_folder = FileUtils.rm_rf(File.join(app.settings.full_projects_path, File.join('project_1/_posts', 'folder1')))
      expect(deleted_folder.size).to eq 1

    end
  end

  describe 'save to post' do
    content = "This is the content of the file."
    file_name = "category1/2016-11-30-empty-file.md"
    project_name = 'project_1'

    config = {
      'key': 'value'
    }

    before { 
      xhr :post, "/#{project_name}/posts/save", post: {
        name: file_name,
        content: content,
        config: config.to_json
      }
    }

    it 'creates successful' do
      data = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      expect(data["success"]).to eq true
      file_path = File.join(app.settings.full_projects_path, File.join(project_name, File.join('_posts', file_name)))
      read_content = File.read(file_path, :encoding => "UTF-8").force_encoding("UTF-8")

      expected_content = "---\nkey: value\n---\n#{content}"
      expect(read_content).to eq expected_content

      # don't delete, only empty
      File.write(file_path, "")
    end
  end

  describe 'save special data with multilines' do
    content = "This is the content\n\n\nof the file."
    file_name = "category1/2016-11-30-empty-file.md"
    project_name = 'project_1'

    config = {
      'key': 'value'
    }

    before { 
      xhr :post, "/#{project_name}/posts/save", post: {
        name: file_name,
        content: content,
        config: config.to_json
      }

      xhr :post, "/#{project_name}/posts/edit", post: {
        name: file_name
      }
    }

    it 'check result' do
      data = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      
      expect(data["success"]).to eq true
      expect(data["content"]).to eq content
      
      file_path = File.join(app.settings.full_projects_path, File.join(project_name, File.join('_posts', file_name)))
      # don't delete, only empty
      File.write(file_path, "")
    end
  end

  describe 'save special data with broken frontmatter' do
    content = "This is th \n--- content\n\n\nof the file."
    file_name = "category1/2016-11-30-empty-file.md"
    project_name = 'project_1'

    config = {
      'key' => 'value'
    }

    before { 
      xhr :post, "/#{project_name}/posts/save", post: {
        name: file_name,
        content: content,
        config: config.to_json
      }

      xhr :post, "/#{project_name}/posts/edit", post: {
        name: file_name
      }
    }

    it 'check result' do
      data = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      
      expect(data["success"]).to eq true
      expect(data["content"]).to eq content
      expect(data["config"]).to eq config
      
      file_path = File.join(app.settings.full_projects_path, File.join(project_name, File.join('_posts', file_name)))
      
      # don't delete, only empty
      File.write(file_path, "")
    end
  end

  describe 'edit file' do
    post_name = "2016-11-21-test1.md"

    before { 
      xhr :post, '/project_1/posts/edit', post: {
        name: post_name
      }
    }

    xit 'get content' do
      data = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      expect(data["success"]).to eq true
      expect(data["content"]).to eq 'This is test1.'
      config = { 'key' => 'value' }
      expect(data["config"]).to eq config
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