# encoding: utf-8
include Jekyll

class ProjectBuildProcessor
  
  @queue = :project

  def self.perform(project_id, environment = 'development')

    ENV['JEKYLL_ENV'] = environment

    source_root_path = File.join(app.settings.full_projects_path, project_id)
    project = Project.new(source_root_path)

    default_config = File.join(app.settings.root, 'jekyll/_config.yml')

    # Settings in later files override settings in earlier files.
    configs = [ default_config, File.join(source_root_path, "_config.yml") ]
    
    opts = {}

    destination_path = File.join(app.settings.full_build_path, project_id+'/'+environment)
    source_path = source_root_path
    
    build_options = {
      "source"      => source_path,
      "destination" => destination_path,
      "config"      => configs,
      "incremental" => true
#      "watch"       => true,
#      "serving"     => true
    }.merge(opts)
    
    log = Log.new(File.join(app.settings.full_log_path, "#{project_id}.log"))
    output = log.capture_outout do
      p "started buid for #{environment}||br||"
      Jekyll::Commands::Build.process(build_options)
    end
    log.write output, "ProjectBuildProcessor", environment
    
  end
  
end