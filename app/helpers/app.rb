# encoding: utf-8
# definition of some html helpers we use in the templates

module Sinatra
  module App
    module Helpers

      # for language purposes
      def t string
        I18n.t(string.to_sym)
      end

      def flashes
        flashes = session[:flashes]
        flashes = [] unless flashes
        session[:flashes] = []
        
        return flashes
      end

      # linking to any party in the application
      def route part = "/", params = {}
        File.join('/', part)+"#depricated"
      end

    end
  end
end