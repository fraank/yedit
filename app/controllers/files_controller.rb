# encoding: utf-8
class FilesController < ApplicationController
  
  def before
    @module = "files"
  end

  named_route '/:project_id/files', :files_index, :get do
    before_all(params['project_id'])
    haml 'files/index'.to_sym, :layout => :'layouts/main'
  end

  named_route '/:project_id/files/tree', :files_tree, :get do
    before_all(params['project_id'])
    filetree = @project.file_tree(false, [], 'Project Root')
    if xhr?
      content_type :json
      ({ success: true, tree: filetree }).to_json
    end
  end 

  named_route '/:project_id/files/create', :files_create, :post do
    before_all(params['project_id'])
    success = false

    if params['file'] && params['file']['name']
      @file = ProjectFile.new(@project, params['file']['name'])
      success = @file.create
      data = { path: @file.path }
    elsif params['folder'] && params['folder']['name']
      @folder = ProjectFolder.new(@project, params['folder']['name'])
      success = @folder.create
      data = { path: '' }
    end

    if success
      if @folder
        flash('Folder created successful.') 
      else
        flash('File created successful.') 
      end
    end

    if xhr?
      content_type :json
      ({ success: success, flashes: flashes }.merge(data)).to_json
    else
      redirect named_route(:files_index)
    end
  end

  named_route '/:project_id/files/edit', :files_save, :post do
    before_all(params['project_id'])
    success = false
    data = {}
    
    if params['file'] && params['file']['name']
      @file = ProjectFile.new(@project, params['file']['name'])
      content = @file.content()
      success = true
      data = { path: @file.path, content: content }
    else
      flash('File not valid.')
    end

    if xhr?
      content_type :json
      ({ success: success, flashes: flashes }.merge(data)).to_json
    else
      redirect named_route(:files_index)
    end
  end  

  named_route '/:project_id/files/save', :files_edit, :post do
    before_all(params['project_id'])
    success = false

    if params['file'] && params['file']['name']
      @file = ProjectFile.new(@project, params['file']['name'])
      if(params['file']['content'] != "")
        content = params['file']['content']
      else
        content = ""
      end
      @file.content(content)
      success = true
      data = { path: @file.path }
    end
    
    flash('File saved successful.') if success
    
    if xhr?
      content_type :json
      ({ success: success, flashes: flashes }.merge(data)).to_json
    else
      redirect named_route(:files_index)
    end

  end

  named_route '/:project_id/files/delete', :files_delete, :post do
    before_all(params['project_id'])
    success = false

    if params['file'] && params['file']['name']
      @file = ProjectFile.new(@project, params['file']['name'])
      success = @file.delete
    elsif params['folder'] && params['folder']['name']
      @folder = ProjectFolder.new(@project, params['folder']['name'])
      if(params['folder']['name'] != "" && params['folder']['name'] != "/")
        success = @folder.delete
      end
    end
    
    if success
      flash('File deleted successful.') if @file
      flash('Folder deleted successful.') if @folder
    else
      flash('File deletion not successful.') if @file
      flash('Folder deletion not successful.') if @folder
    end
    
    if xhr?
      content_type :json
      ({ success: success, flashes: flashes }).to_json
    else
      redirect named_route(:files_index)
    end

  end

end