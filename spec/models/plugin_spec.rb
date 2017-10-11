# encoding: utf-8
require_relative '../spec_helper'

describe 'theme model behaviour' do
  
  before(:all) do
    app.set :full_plugins_path, File.join(File.dirname(__FILE__), '../data/plugins')
  end

  describe 'static theme functionality' do

    it 'list all themes with gemspec' do

      themes = Plugin.all(app.full_plugins_path)
      
      plugin_name = 'plugin1'
      plugin_path = File.join(File.dirname(__FILE__), '../data/plugins/'+plugin_name)
      expect(themes).to include(name: plugin_name, path: plugin_path, gemspec: File.join(plugin_path, plugin_name+".gemspec"))

      plugin_name = 'plugin2'
      plugin_path = File.join(File.dirname(__FILE__), '../data/plugins/'+plugin_name)
      expect(themes).to include(name: plugin_name, path: plugin_path, gemspec: File.join(plugin_path, plugin_name+".gemspec"))
      
      plugin_name = 'plugin3'
      plugin_path = File.join(File.dirname(__FILE__), '../data/plugins/'+plugin_name)
      expect(themes).not_to include(name: plugin_name, path: plugin_path, gemspec: File.join(plugin_path, plugin_name+".gemspec"))

    end

  end

end