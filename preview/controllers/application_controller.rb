class ApplicationController < Sinatra::Base

  set :root, File.join(File.dirname(__FILE__), '../..')

  register Sinatra::ConfigFile

  # load config
  config_file 'config/config.yml'

  configure do
    set :bind, '0.0.0.0'
    set :port, settings.preview["port"]

    set :full_projects_path, Proc.new { File.join(root, projects_path) }
    set :full_build_path, Proc.new { File.join(root, build_path) }
  end

  get '*' do
    if session[:sssio_project]
      project = session[:sssio_project]
      environment = session[:sssio_project_environment]
    
      # set header so we can get content
      headers 'X-Frame-Options' => 'ALLOWALL'
      
      path = File.join(File.join(settings.full_build_path, project), environment)
      
      # now proxy the content
      file = File.join("#{path}/#{params[:splat].first}")
      file = File.join(file, "index.html") if File.directory?(file)

      if(File.exist?(file) && !params[:splat].first.empty?)
        send_file file
      else
        return "Sorry. File (#{file}) not found in #{session['current_project']}.#{session['current_subproject']}."
      end
    else
      "Sorry. No project is active."
    end
  end

end