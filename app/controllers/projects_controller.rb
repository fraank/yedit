# encoding: utf-8
require 'time'

class ProjectsController < ApplicationController

  named_route '/p', :projects_index, :get do
    before_all
    
    @header = t('projects.index.header')
    @bc << { name: t('projects.index.title') }

    haml 'projects/index'.to_sym, :layout => :'layouts/main'
  end

  # project home
  named_route '/:project_id', :projects_show, :get do
    before_all(params['project_id'])
    if @project.exists?
      @header = "Project: "+@project.id
      
      @files = @project.last_files(5)
      @posts = @project.last_posts(5)

      haml 'projects/show'.to_sym, :layout => :'layouts/main'
    else
      status 404
    end
  end

  # show config
  named_route '/:project_id/p/config', :projects_config, :get do
    before_all(params['project_id'])
    
    @header = t('projects.config.header')
    @bc << { name: t('projects.config.title') }

    @module = 'config'

    @configs = @project.all_config_files

    # return config of project
    haml 'projects/config'.to_sym, :layout => :'layouts/main'
  end

  # get config data as json for project
  named_route '/:project_id/p/config/edit', :projects_config_edit, :post do
    config_file = params['file']
    if xhr?
      before_all(params['project_id'])
      config = @project.get_config(config_file)
      content_type :json
      ({ success: true, config: config }).to_json
    end
  end
  
  # save config data as json for project / subproject
  named_route '/:project_id/p/config/save', :projects_config_save, :post do
    config_file = params['file']
    if xhr?
      before_all(params['project_id'])
      new_config = JSON.parse(params['config'])

      config = @project.save_config(config_file, new_config)
      content_type :json
      ({ success: true, config: new_config }).to_json
    end
  end
  
  # activate project
  named_route '/:project_id/p/activate', :projects_activate, :get do
    params['env'] ||= 'development'
    @project = Project.new(File.join(settings.full_projects_path, params['project_id']))
    if @project.exists?
      session[:sssio_project] = @project.id
      session[:sssio_project_environment] = params['env']
      flash('Project '+@project.id+' successful activated.')
      redirect named_route(:projects_live)
    else
      status 404
    end
  end

  # build project
  named_route '/:project_id/p/build', :projects_build, :get do
    params['env'] ||= 'development'
    before_all(params['project_id'])
    
    Resque.enqueue(ProjectBuildProcessor, params['project_id'], params['env'])
    flash('Build of project successful sheduled.')
    redirect named_route(:projects_live)
  end

  # deploy project
  named_route '/:project_id/p/deploy', :projects_deploy, :get do
    params['env'] ||= 'production'
    before_all(params['project_id'])
    
    Resque.enqueue(ProjectDeployProcessor, params['project_id'], params['env'])
    flash('Deploy of project successful sheduled.')
    redirect named_route(:projects_live)
  end

  # dashboard for live activity
  named_route '/:project_id/p/live', :projects_live, :get do
    
    @module = 'live'

    before_all(params['project_id'])
    @header = "Actions for "+@project.id

    deployment = Deployment.new(@project)

    @deploy_environments = deployment.environments()

    require 'resque'

    @worker_status = Resque.info

    log = Log.new(File.join(settings.full_log_path, "#{@project.id}.log"))
    logs = log.recent

    @logs = []

    logs.each do |log|
      @logs << {
        :label => ((log.attribute("method").to_s == "error")? "label-danger": "label-success"),
        :label_text => log.attribute("method"),
        :time => Time.parse(log.attribute("start").to_s),
        :header => log.attribute("identifier"),
        :text => log.to_s.gsub("||br||", "<br />")
      }
    end

    
    Resque::Failure.all(0,20).each do |error|
      @logs << {
        :label => 'label-danger',
        :label_text =>  error['exception'],
        :time => Time.parse(error['failed_at'].to_s),
        :header => error['payload']['class']+ "("+error['payload']['args'].join(', ')+")",
        :text => error['error'] + "<br/>"
      }
    end

    @logs = @logs.sort_by { |k| k[:time] }.reverse

    haml :'projects/live', :layout => :'layouts/main'
  end

  # create a new project
  named_route '/p/create', :projects_create, :post do
    project = Project.new(File.join(settings.full_projects_path, "#{params['project_id']}"))
    created = project.create(File.join(settings.root, 'jekyll/scaffolds/projects'), 'default')
    if created
      flash('Project successful created.')
      redirect named_route(:projects_show, project_id: project.id)
    else
      redirect named_route(:projects_index)
    end
  end

end
