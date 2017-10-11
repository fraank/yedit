# encoding: utf-8
# simple logging class for readable output of command line executes
class Log

  require 'open3'
  require 'rexml/document'

  def initialize log_file
    @timestamp = get_time
    @stop = @timestamp
    @log_file = log_file
  end

  def get_time()
    return Time.now.strftime("%Y-%m-%d %H:%M:%S")
  end

  def exists?
    File.exist?(@log_file)
  end

  def recent max=5
    return [] if !exists?
    file = File.open( @log_file )
    doc = REXML::Document.new "<log_items>"+file.read+"</log_items>"
    return doc.elements.collect('//log_item') { |f| f }.last(max).reverse
  end

  def write text, identifier = '', method = 'default'
    doc = REXML::Document.new
    root = doc.add_element "log_item"
    
    root.add_attribute 'method', method
    root.add_attribute 'identifier', identifier
    root.add_attribute 'timestamp', @timestamp

    root.add_attribute 'start', @timestamp
    root.add_attribute 'stop', get_time

    root.add_text text

    File.open(@log_file, 'ab') { |f| f.write(doc.to_s+"\n") }
  end

  def to_safe_string str
    return str.strip.gsub("\n", "||br||").gsub(/[\u0001-\u001A]/ , '').gsub(/[^[:print:]]/ , '') # working
  end

  # executing a shell command and log the output
  def execute cmd, identifier = ''
    success = true

    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      err = to_safe_string(stderr.read)
      if err != ''
        write(err, identifier, 'error')
        success = false
      end 
      out = to_safe_string(stdout.read)
      if out != ''
        write(out, identifier, 'default')
      end
    end
    return success
  end

  def capture_outout
    begin
      old_stdout = $stdout
      $stdout = StringIO.new('','w')
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end

end