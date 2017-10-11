require_relative '../spec_helper'

describe 'projects_controller in project context', :type => :controller do

  before(:context) do
    @application_controller = "ProjectsController"
  end

  before(:all) do
    app.set :full_projects_path, File.join(File.dirname(__FILE__), '../data/projects')
  end

  describe 'GET /p' do
    before { get '/p' }
    it 'succeed' do
      expect(last_response.status).to eq 200
    end
    it 'shows all projects' do
      expect(last_response.body.scan(/project\_box/).count).to eq 3
    end
  end

  describe 'GET existent /project_name' do
    before { get '/project_1' }
    it 'succeed' do
      expect(last_response.status).to eq 200
    end
  end

  describe 'GET non existent /project_name' do
    before { get '/project_5' }
    it 'fails' do
      expect(last_response.status).to eq 404
    end
  end

  describe 'activate non existent root-project' do
    before { get '/project_non_existent/p/activate' }
    it 'should respond with an error' do
      expect(last_response.status).to eq 404
    end
  end

  describe 'activate existent Root-Project' do
    before { get '/project_1/p/activate' }
    it 'should be redirected' do
      expect(last_response.status).to eq 302
    end
  end

  describe "write config data" do

    describe 'GET config for Project 1' do
      before { get '/project_1/p/config' }
      it 'should not fails' do
        expect(last_response.status).to eq 200
      end
    end

    describe 'GET config data as json for Project 2' do
      it 'should not fails' do
        xhr :post, '/project_2/p/config/edit', { file: '_config.yml' }
        expect(last_response.status).to eq 200

        data = JSON.parse(last_response.body)
        expect(data["config"]["lang"]).to eq 'de'
      end
    end

    describe 'write config data as json for Project 2' do
      it 'should not fails' do
        # get old
        xhr :post, '/project_2/p/config/edit', { file: '_config.yml' }
        expect(last_response.status).to eq 200

        data = JSON.parse(last_response.body)
        expect(data["config"]["lang"]).to eq 'de'

        # write new
        data["config"]['new_value'] = "test"
        xhr :post, '/project_2/p/config/save', {
          file: '_config.yml',
          config: data["config"].to_json
        }

        # check response
        data = JSON.parse(last_response.body)
        expect(data["success"]).to eq true

        # check new
        xhr :post, '/project_2/p/config/edit', { file: '_config.yml' }
        expect(last_response.status).to eq 200

        data = JSON.parse(last_response.body)
        expect(data["config"]["new_value"]).to eq "test"
      end
    end

  end


end