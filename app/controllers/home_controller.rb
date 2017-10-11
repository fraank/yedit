# encoding: utf-8
class HomeController < ApplicationController

  named_route '/', :root, :get do
    before_all
    
    @header = t('home.index.header')
    @subheader = t('home.index.subheader')
    
    @themes = @plugins = []
    @themes = Theme.all(settings.full_themes_path) if defined? settings.full_themes_path
    @plugins = Plugin.all(settings.full_plugins_path) if defined? settings.full_plugins_path

    haml 'home/index'.to_sym, :layout => :'layouts/main'  
  end

end