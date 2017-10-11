# encoding: utf-8

# handles files
class ProjectFile

  # init new file to work with
  def initialize project, file = false
    @project = project
    init(file) if file
  end

  def init file
    @file = file
    @path = File.join(@project.path, file)
    @extension = File.extname(file)
    @content = false
  end

  def exists?
    File.exist?(path)
  end

  def file
    @file
  end

  def path
    @path
  end

  def extension
    @extension
  end

  # create a new file
  def create
    if exists?
      return false
    else
      # create folder if not existent
      unless File.directory?(File.dirname(path))
        FileUtils.mkdir_p(File.dirname(path))
      end
      File.write(path, "")
      return true
    end
  end

  def create_post file_name
    project_relative_path = '_posts'
    project_folder = ProjectFolder.new(@project, project_relative_path)
    project_folder.create unless project_folder.exists?
    
    folder_name = File.dirname(file_name).split('/').collect{ |folder| ProjectFile.to_slug(folder) }.join('/')
    file_name = File.basename(file_name)

    real_file_name = File.join(File.join(project_relative_path, folder_name), DateTime.now.strftime('%Y-%m-%d') + "-" + ProjectFile.to_slug(file_name) + ".md")

    init(real_file_name)
    return create
  end

  def delete
    if exists?
      FileUtils.rm(path)
      return true
    end
    false
  end

  # get or writes the content of the file
  def content content = false
    if content
      if content != ""
        create unless exists?
        @content = content
        File.write(path, @content)
        return true
      else
        return false
      end
    else
      @content = File.read(path, :encoding => "UTF-8").force_encoding("UTF-8")
      return @content
    end
  end

  # get frontmatter config
  def config
    string_data = only_frontmatter()
    if string_data == "" || string_data == false || string_data == "\n" || string_data == "\n\n"
      data = {} 
    else
      data = YAML.load(string_data)
    end
    return data
  end

  # get content without frontmatter
  def only_content
    content unless @content
    found = content.gsub(/\A---(.|\n)*?---/, "")
    
    # remove empty lines
    found = found.lstrip # leading whitespace removed from beginning
    found = found.chomp # is it will remove \n, \r, and \r\n from the end

    return found
  end

  # get only frontmatter without enclosing tags i.e. '---'
  def only_frontmatter
    found = @content.match(/\A---(.|\n)*?---/)
    if found.size > 0 
      found = found[0] 
      
      # remove ---
      found = found.gsub /^\-\-\-/, '' # from beginning
      found = found.gsub /\-\-\-$/, '' # from end
      return found
    end
    return ""
  end

  # where can we preview this file?
  def get_preview_path
    paths = @file_path.split("/")
    if(paths.first.start_with?("_"))
      return false
    elsif @extension == ".html"
      return @file_path
    elsif  @extension == ".md"
      return @file_path.gsub('.md', '/index.html')
    else
      return false
    end
  end

  def self.to_slug str
    str.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end

end