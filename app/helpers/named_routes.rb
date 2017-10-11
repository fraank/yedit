module Sinatra
  module App
    module RouteHelpers
      
      def named_route name=false, options = {}
        unless name
          ret = settings.named_routes
        else
          ret = settings.named_routes[name.to_sym]

          if !ret || ret == nil
            p "route #{name} not found."
            return ""
          end
          
          # add current project
          ret = ret.gsub(":project_id", @project.id) if @project && @project.id != "" && !options[:project_id]
          options.each do |key, value|
            if key == '*' || key == :'*'
              
              ret = ret.gsub("*", value.to_s)
            else
              ret = ret.gsub(":"+key.to_s, value.to_s)
            end
          end
        end
        if options[:params] && options[:params] != ""
          return ret + options[:params]
        end
        return ret
      end

    end
  end
end