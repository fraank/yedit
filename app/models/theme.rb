class Theme

  def self.all path = false
    themes = []
    
    plugins_folder = File.join(path, '*/*.gemspec')

    Dir[plugins_folder].each do |gemspec_file|
      dir_name = File.dirname(gemspec_file)
      themes << {
        name: File.basename(gemspec_file, File.extname(gemspec_file)),
        path: dir_name,
        gemspec: gemspec_file
      }
    end
    return themes
  end

end