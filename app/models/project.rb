# encoding: utf-8
require 'yaml'
require 'find'
require 'pathname'

# handles projects
class Project

  # initialize project with path
  def initialize project_path
    @id = project_path.split('/').last.downcase
    @name = project_path.split('/').last.downcase
    @path = project_path
  end

  # create empty project
  def create_empty
    return false if File.directory?(path)
    return Dir.mkdir(path)
  end

  # create new project based on scaffold_layout
  def create scaffold_layouts_path, scaffold_layout = 'default'
    return false if !id_valid?
    return false if exists?
    create_path = File.join(scaffold_layouts_path, scaffold_layout+'/.')
    if create_empty
      FileUtils.cp_r(create_path, path)
      return true
    end
    return false
  end

  def id_valid?
    (@id =~ /[^a-zA-Z0-9\_\-]/).nil?
  end

  # get id
  def id
    @id
  end

  # get name
  def name
    @name+"#depr"
  end

  def path
    @path
  end

  # check if the root-folder has an index-file
  def root_valid?
    index_files = Dir[File.join(path, "index.*")].count
    return true if index_files > 0
    return false
  end

  # get all config-files for project
  def all_config_files
    #files = Dir[File.join(path, "_config.yml")]
    files = Dir[File.join(path, "_*.yml")]
    return files
  end

  # get config file relevat for project
  def config_files
    files = Dir[File.join(path, "_config.yml")]
    return files
  end

  # helper function 
  def config_deep_merge!(tgt_hash, src_hash)
    tgt_hash.merge!(src_hash) { |key, oldval, newval|
      if oldval.kind_of?(Hash) && newval.kind_of?(Hash)
        config_deep_merge!(oldval, newval)
      else
        newval
      end
    }
  end

  # get config
  def config()
    configs = config_files()
    yml = {}
    configs.each do |config|
      yml_new = YAML.load_file(config)
      config_deep_merge!(yml, yml_new)
    end
    return yml
  end

  # return bare (unchanged) config
  def get_config config_file = "_config.yml"
    config_file = File.join(path, config_file)
    yml_data = YAML.load_file(config_file)
    return yml_data
  end

  # safe bare config
  def save_config config_file = "_config.yml", data = {}
    config_file = File.join(path, config_file)
    File.open(config_file, 'w') {|f| f.write data.to_yaml }
    return data
  end

  # create a recursive file-tree of project files
  def file_tree path = false, only_extensions = [], name = nil
    path = @path unless path
    data = { :name => (name || path) }
    data[:children] = children = []
    if(File.directory?(path) && File.exists?(path))
      Dir.foreach(path) do |entry|
        next if entry == '..' or entry == '.' or entry.start_with?(".")
        full_path = File.join(path, entry)
        if File.directory?(full_path)
          children << file_tree(full_path, only_extensions, entry)
        else
          if only_extensions.size > 0
            children << { :name => entry } if only_extensions.all? {|extension| true if entry.end_with?(extension) }
          else
            children << { :name => entry }
          end
        end
      end
    end
    return data
  end

  # create a recursive file-list of project files
  def file_list path = false, only_extensions = []
    data = []
    path = @path unless path
    if File.exists?(path) && File.directory?(path)
      Dir.foreach(path) do |entry|
        next if entry == '..' or entry == '.' or entry.start_with?(".")
        full_path = File.join(path, entry)
        if File.directory?(full_path)
          data.concat(file_list(full_path, only_extensions))
        else
          if only_extensions.size > 0
            data <<  { 
              :name => entry,
              :path => full_path
            } if only_extensions.all? {|extension| true if entry.end_with?(extension) }
          else
            data << { 
              :name => entry,
              :path => full_path
            }
          end
        end
      end
    end
    return data
  end

  # does the project exists?
  def exists?
    return true if File.directory?(@path)
    false
  end

  # doew the project has a preview?
  def preview?
    false
  end

  # get files of 
  def files folder = false
    return file_tree(File.join(@path, folder)) if folder 
    return file_tree(@path)
  end

  def last_files count = 5, only_extensions = ['.html']
    files = file_list(@path, only_extensions)
    files = files[0..count-1] if files.size > 0
    return files
  end

  def last_posts count = 5
    posts = file_list(File.join(@path, '_posts'), ['.md'])
    posts = posts[0..count-1] if posts.size > 0
    return posts
  end

  # find all available projects on this machine
  def self.get_all(path)
    projects = []
    Dir.entries(path).select{ |entry| File.directory? File.join(path, entry) and !(entry =='.' || entry == '..') }.each do |project_path|
      project = Project.new(File.join(path, project_path))
      projects << project
    end
    return projects
  end

  # find all scaffold_layouts
  def self.get_all_scaffold_layouts scaffold_layouts_path
    return [] if !File.directory?(scaffold_layouts_path)
    layouts = []
    Dir.foreach(scaffold_layouts_path) do |entry|
      if File.directory?(File.join(scaffold_layouts_path, entry)) && entry != "." && entry != ".."
        layouts << entry
      end
    end
    return layouts
  end

end