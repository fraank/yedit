# encoding: utf-8
class DocsController < ApplicationController
  
  get '/doc' do
    before_all
    haml :docs, :layout => :'layouts/main'  
  end

end