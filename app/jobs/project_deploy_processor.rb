# encoding: utf-8
include Jekyll

class ProjectDeployProcessor
  
  @queue = :project

  def self.perform(project_id, environment = 'production')

    project = Project.new(File.join(app.settings.full_projects_path, project_id))
    
    deployment = Deployment.new(project, environment)
    deployments = deployment.deploy(app.settings.full_build_path)

    log = Log.new(File.join(app.settings.full_log_path, "#{project_id}.log"))
    deployments.each do |cur_deployment|

      log_txt = ""

      created = cur_deployment.get_created()
      if created.size > 0
        log_txt = log_txt+"||br||#{created.size} created files: " + created.collect{|item| item[:key] }.join(", ")
      end
    
      cur_deployment.get_updated
      updated = cur_deployment.get_updated()
      if updated.size > 0
        log_txt = log_txt+"||br||#{updated.size} updated files: " + updated.collect{|item| item[:key] }.join(", ")
      end

      deleted = cur_deployment.get_deleted()
      if deleted.size > 0
        log_txt = log_txt+"||br||#{deleted.size} deleted files: " + deleted.collect{|item| item[:key] }.join(", ")
      end

      ignored = cur_deployment.get_ignored()
      if ignored.size > 0
        log_txt = log_txt+"||br||#{ignored.size} ignored files: " + ignored.collect{|item| item[:key] }.join(", ")
      end

      if cur_deployment.respond_to?(:invalidate) && cur_deployment.invalidate?
        cur_deployment.invalidate
        log_txt = log_txt+"||br|| and successful deployed to "+cur_deployment.invalidation_name
      end

      log.write "Deployed #{project_id} with #{cur_deployment.get_request_count()} requests."+log_txt, cur_deployment.iname, environment

    end
    
  end
  
end