# encoding: utf-8

# handles files
class ProjectFolder

  # init new file to work with
  def initialize project, folder
    @folder = File.join(project.path, folder)
  end

  def exists?
    File.directory?(@folder)
  end

  # return the file with folder
  def path
    @folder
  end

  # create a new folder
  def create
    if exists?
      return false
    else
      Dir.mkdir(@folder)
      return true
    end
  end

  def delete
    if exists?
      FileUtils.remove_dir(@folder)
      return true
    end
    return false
  end

end