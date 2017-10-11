# encoding: utf-8
require_relative '../spec_helper'

describe 'theme model behaviour' do
  
  before(:all) do
    app.set :full_themes_path, File.join(File.dirname(__FILE__), '../data/themes')
  end

  describe 'static theme functionality' do

    it 'list all themes with gemspec' do

      themes = Theme.all(app.full_themes_path)
      
      theme_name = 'theme1-jekyll'
      theme_path = File.join(File.dirname(__FILE__), '../data/themes/'+theme_name)
      expect(themes).to include(name: theme_name, path: theme_path, gemspec: File.join(theme_path, theme_name+".gemspec"))

      theme_name = 'theme2-jekyll'
      theme_path = File.join(File.dirname(__FILE__), '../data/themes/'+theme_name)
      expect(themes).to include(name: theme_name, path: theme_path, gemspec: File.join(theme_path, theme_name+".gemspec"))
      
      theme_name = 'theme3-jekyll'
      theme_path = File.join(File.dirname(__FILE__), '../data/themes/'+theme_name)
      expect(themes).not_to include(name: theme_name, path: theme_path, gemspec: File.join(theme_path, theme_name+".gemspec"))

    end

  end

end