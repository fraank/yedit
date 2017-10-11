module Sinatra
  module NamedRoute
    extend Sinatra::Extension

    configure do
      set :named_routes, {}
    end

    def named_route url, name, method, &block
      
      # store route
      settings.named_routes[name.to_sym] = url

      #make call
      if method.to_sym == :get
        get url do 
          instance_eval(&block)
        end
      elsif method.to_sym == :post
        post url do 
          instance_eval(&block)
        end
      elsif method.to_sym == :delete
        delete url do 
          instance_eval(&block)
        end
      end
    end

  end
  register NamedRoute

end