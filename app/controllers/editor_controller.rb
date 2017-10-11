# encoding: utf-8
class EditorController < ApplicationController

  def before
    @module = "editor"
  end

  named_route '/:project_id/editor', :editor_index, :get do
    before_all(params['project_id'])
    
    @header = t('editor.index.header')
    @bc << { :name => t('editor.index.title') }

    haml 'editor/index'.to_sym, :layout => :'layouts/main'
  end
  
  named_route '/:project_id/editor/tree', :editor_tree, :get do
    before_all(params['project_id'])
    filetree = @project.file_tree(false, ['.html'], 'Files Root')
    if xhr?
      content_type :json
      ({ success: true, tree: filetree }).to_json
    end
  end 

end