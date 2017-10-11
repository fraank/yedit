# encoding: utf-8
require './bootstrap'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

use Rack::Session::Cookie, :key => 'rack.session',
  #:domain => '192.168.166.6',
  :path => '/',
  :expire_after => 2592000,
  :secret => 'change_me',
  :old_secret => 'also_change_me'

run Rack::Cascade.new([
  ApplicationController,
])