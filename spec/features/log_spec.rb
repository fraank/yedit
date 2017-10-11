# encoding: utf-8
require_relative '../spec_helper'

describe 'Logs for Output of Console' do

  before(:all) do
    app.set :full_log_path, File.join(File.dirname(__FILE__), '../data/tmp/logs')
  end
  
  describe 'GET /' do
    
    it 'should fail because file is not existent' do
      log_file = File.join(app.settings.full_log_path, "test.log")
      log = Log.new(log_file)
      expect(log.recent).to eq []
    end

    it 'write simple file' do
      log_file = File.join(app.settings.full_log_path, "test.log")
      log = Log.new(log_file)
      log.write('This is a test.', 'Test')

      expect(File.exist?(log_file)).to be true
      expect(log.recent.size).to eq 1

      log.write('This is a test2.', 'Test2')
      expect(log.recent.size).to eq 2

      # delete it afterwards
      File.delete(log_file)
    end

  end
end