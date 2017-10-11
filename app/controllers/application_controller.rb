class ApplicationController < Sinatra::Base
  
  set :root, File.join(File.dirname(__FILE__), '../..')

  register Sinatra::NamedRoute
  register Sinatra::ConfigFile

  helpers Sinatra::App::Helpers
  helpers Sinatra::App::RouteHelpers

  # load config
  config_file 'config/config.yml'
  
  configure do
    set :named_routes, {}
    set :views, Proc.new { File.join(root, "app/views") }
    
    #set :public_folder, Proc.new { File.join(root, "../../app/assets") }
    set :bind, '0.0.0.0'
    set :port, settings.editor["port"]

    set :full_log_path, Proc.new { File.join(root, log_path) }
    set :full_projects_path, Proc.new { File.join(root, projects_path) }
    set :full_build_path, Proc.new { File.join(root, build_path) }
    
    
    set :full_themes_path, Proc.new { File.join(root, themes_path) } if defined? themes_path
    set :full_plugins_path, Proc.new { File.join(root, plugins_path) } if defined? plugins_path

    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.load_path = Dir[File.join(root, 'app/i18n', '*.yml')]
    I18n.backend.load_translations
    
    I18n.config.available_locales = [ :en, :de ]
  end

  # for the routes
  # we always want to be in the project-contect
  # this contect is not session based, just only via the /project_name/ in the url
  # so we can use different projects in different tabs (for copy and paste for example)
  def before_all(project_id = false)
    # set locale
    I18n.default_locale = :en
    
    @projects = Project::get_all(settings.full_projects_path)

    @bc = []
    
    if project_id
      @project = Project.new(File.join(settings.full_projects_path, project_id))
      @bc << { name: @project.id, link: named_route(:projects_show, project_id: @project.id) }
    end
    
    @preview_url = URI::HTTP.build(:host => settings.preview["domain"], :port => settings.preview["port"], :protocol =>  settings.preview["protocol"])

    # for frontend
    @current_project = session[:sssio_project]
    @current_project_environment = session[:sssio_project_environment]
    
    if @current_project_environment == "development"
      @current_project_environment_class = "orange"
    elsif @current_project_environment == "production"
      @current_project_environment_class = "green"
    elsif @current_project_environment != ""
      @current_project_environment_class = "blue"
    end

    if self.respond_to? 'before'
      self.before()
    end

  end

  # sets a new flash for everything
  def flash text, type = 'success', title = false
    session[:flashes] = [] unless session[:flashes]
    session[:flashes] << {
      type: type,
      text: text,
      title: title
    }
  end

  # is the current request an ajax request?
  def xhr?
    @env['HTTP_X_REQUESTED_WITH'] =~ /XMLHttpRequest/i
  end

end