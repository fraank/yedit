# encoding: utf-8
class PostsController < ApplicationController

  def before
    @module = "posts"
  end

  named_route '/:project_id/posts', :posts_index, :get do
    before_all(params['project_id'])
    haml 'posts/index'.to_sym, :layout => :'layouts/main'
  end

  named_route '/:project_id/posts/tree', :posts_tree, :get do
    before_all(params['project_id'])
    tree = @project.file_tree(File.join(@project.path, '_posts'), ['.md'], 'Posts')
    if xhr?
      content_type :json
      ({ success: true, tree: tree }).to_json
    end
  end  

  named_route '/:project_id/posts/create', :posts_create, :post do
    before_all(params['project_id'])
    success = false
    
    if params['post'] && params['post']['name']
      @post = ProjectFile.new(@project, File.join('_posts', params['post']['name']))
      success = @post.create_post(params['post']['name'])
      data = { name: File.basename(@post.file), path: @post.file.gsub('_posts/', '') }
    end

    if success
      flash('Post created successful.') 
    end

    if xhr?
      content_type :json
      ({ success: success, flashes: flashes }.merge(data)).to_json
    else
      redirect named_route(:posts_index)
    end
  end

  named_route '/:project_id/posts/edit', :posts_edit, :post do
    before_all(params['project_id'])
    success = false
    data = {}
    
    if params['post'] && params['post']['name']
      @post = ProjectFile.new(@project, File.join('_posts', params['post']['name']))
      content = @post.only_content()
      config = @post.config()
      success = true
      data = { path: @post.path, content: content, config: config }
    else
      flash('File not valid.')
    end

    if xhr?
      content_type :json
      ({ success: success, flashes: flashes }.merge(data)).to_json
    else
      redirect named_route(:posts_index)
    end
  end  

  named_route '/:project_id/posts/save', :posts_save, :post do
    before_all(params['project_id'])
    success = false

    if params['post'] && params['post']['name']
      @post = ProjectFile.new(@project, File.join('_posts', params['post']['name']))

      if params['post']['config'] != ""
        config_string = JSON.parse(params['post']['config']).to_yaml
      else
        config_string = "---\n"
      end

      if(params['post']['content'] != "")
        content = params['post']['content']
      else
        content = ""
      end
      
      @post.content(config_string+"---\n"+content)
      
      success = true
      data = { path: @post.path }
    end
    
    flash('File saved successful.') if success
    
    if xhr?
      content_type :json
      ({ success: success, flashes: flashes }.merge(data)).to_json
    else
      redirect named_route(:posts_index)
    end

  end

  named_route '/:project_id/posts/delete', :posts_delete, :post do
    before_all(params['project_id'])
    success = false

    if params['post'] && params['post']['name']
      @file = ProjectFile.new(@project, params['post']['name'])
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
      redirect named_route(:posts_index)
    end

  end

end