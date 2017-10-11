# encoding: utf-8
# deployment class
require 'aws-sdk'
require 'securerandom'

class Deployment::Aws < Deployment

  def iname
    "AWS " + @environment
  end

  def invalidation_name
    @config['aws']['cloudfront_distribution_id']
  end

  # make the file looking nice
  def clean_file_target file_target
    if file_target && !file_target.empty?
      # remove leading slashes
      file_target.sub!(/^\//, '')
    end
    return file_target
  end

  def credentials
    return @credentials if @credentials
    @credentials = ::Aws::Credentials.new(
      @config['aws']['access_key_id'], @config['aws']['secret_access_key']
    )
  end

  def open_connection
    @s3 = ::Aws::S3::Resource.new(
      region: @config['aws']['region'],
      credentials: credentials
    )
    @bucket = @s3.bucket(@config['aws']['s3_bucket'])
    
    return true if @s3 && @bucket
    return false
  end

  # remote section
  def remote_files_all folder = "/"
    open_connection unless @s3
    files = []
    @bucket.objects.each do |item|
      files << item.key
    end
    return files
  end

  # do syncing of one file
  def file_sync file_dest, file_target
    open_connection unless @s3
    return false if File.directory?(file_dest)
    if remote_file_exists?(file_target) == true
      ret = file_change(file_dest, file_target)
    else
      ret = file_create(file_dest, file_target)
    end
    return ret
  end

  # file exists: upload when changed set log
  def file_change file_dest, file_target
    open_connection unless @s3

    if remote_file_changed?(file_dest, file_target)
      file_upload(file_dest, file_target)
      @updated << {
        key: file_target
      }
      return true
    end
    @ignored << {
      key: file_target
    }
    return true
  end

  # create a file and set log
  def file_create file_dest, file_target
    open_connection unless @s3
    file_target = clean_file_target(file_target)
    upload_succ = file_upload(file_dest, file_target)
    if upload_succ
      @created << {
        key: file_target
      }
      return true
    end
    return false
  end

  def get_local_file_header file
    mime_type = self.get_mime_type(file)
    mime_type = "text/plain" unless mime_type

    headers = {
      :content_type => mime_type
    }
    return headers
  end

  # pure file upload
  def file_upload file_dest, file_target
    open_connection unless @s3
    file_target = clean_file_target(file_target)

    @request_count = @request_count + 1
    file_conf = {
      acl: 'public-read',
      key: file_target,
      body: IO.read(file_dest),
      expires: Time.now
    }.merge(get_local_file_header(file_dest))
    file_succ = @bucket.put_object(file_conf)
    return true if file_succ
    return false
  end

  # did the file has changed?
  def remote_file_changed? file_dest, file_target = false
    open_connection unless @s3

    # set just the file name
    file_target = file_dest if !file_target
    file_target = clean_file_target(file_target)
    begin
      @request_count = @request_count + 1
      obj = @bucket.object(file_target)
      if obj.etag.gsub("\"", "") != Digest::MD5.hexdigest(File.read(file_dest))
        return true 
      end
    rescue
    end
    return false
  end

  def get_remote_file(file_target)
    return @bucket.object(file_target)
  end

  # checks exstance of file and content
  def remote_file_exists? file_target
    open_connection unless @s3
    file_target = clean_file_target(file_target)

    @request_count = @request_count + 1
    obj = get_remote_file(file_target)
    return true if obj && obj.exists?
    return false
  end

  # delete file
  def file_delete file_target
    open_connection unless @s3
    file_target = clean_file_target(file_target)

    @request_count = @request_count + 1
    obj = @bucket.object(file_target)
    if obj && obj.exists?
      obj.delete
      @deleted << {
        key: file_target
      }
      return true
    end
    return false
  end

  # shoule we run an invalidation?
  def invalidate?
    return invalidation_name && invalidation_name != nil && invalidation_name.to_s != ""
  end

  # send all changed files as invalidations 
  def invalidate
    if invalidate?
      files = invalidations
      return false if files.size == 0

      cloudfront ||= ::Aws::CloudFront::Client.new(region: @config['aws']['region'], credentials: credentials)
      if cloudfront
        invalidate_name = SecureRandom.hex(32)
        success = cloudfront.create_invalidation(distribution_id: @config['aws']['cloudfront_distribution_id'], invalidation_batch: { caller_reference: invalidate_name, paths: { items: files, quantity: files.size } } )
        return files if success
      end
      return false
    end
  end

end