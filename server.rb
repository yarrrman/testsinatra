require 'sinatra'
require 'sinatra/reloader'

require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/mydatabase.sqlite3")

class StoredFile
	include DataMapper::Resource
	property :id, Integer, :serial => true
	property :filname, String, :nullable => false
	property :created_at, DateTime

	default_scope(:default).update(:order => [:created_at.desc])
end

DataMapper.auto_upgrade!


get '/' do
	@files = StoredFile.all
	erb :list
end

post '/' do 
	tempfile = params['file'][:tempfile]
	@file = StoredFile.new :filname => params['file'][:filename]
	@file.save!
	File.copy(tempfile.path, "./files/#{@file.id}.upload")
	redirect '/'
end

get '/:id' do 
	@file = StoredFile.get(params[:id])
	send_file "./files/#{params[:id]}.upload", :filename => @file.filename, :type => 'Application/octet-stream'
	redirect '/'
end

get '/:id/delete' do 
	StoredFile.get(params[:id]).destroy
	File.delete("./files/#{params[:id]}.upload")
	redirect '/'
end
