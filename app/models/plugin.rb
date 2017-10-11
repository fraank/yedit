class Plugin

  def self.all path = false
    plugins = []
    
    plugins_folder = File.join(path, '*/*.gemspec')

    Dir[plugins_folder].each do |gemspec_file|
      dir_name = File.dirname(gemspec_file)
      plugins << {
        name: File.basename(gemspec_file, File.extname(gemspec_file)),
        path: dir_name,
        gemspec: gemspec_file
      }
    end
    return plugins
  end

end