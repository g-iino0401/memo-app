# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'cgi'

FILE_PATH = 'public/memos.json'

def get_memos
  if File.exist?(FILE_PATH) && !File.zero?(FILE_PATH)
    File.open(FILE_PATH) { |f| JSON.parse(f.read) }
  else
    sample_file_path = 'public/sample.json'
    File.exist?(sample_file_path) && !File.zero?(sample_file_path)
    File.open(sample_file_path) { |f| JSON.parse(f.read) }
  end
end

def set_memos(memos)
  File.open(FILE_PATH, 'w') { |f| JSON.dump(memos, f) }
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = get_memos
  erb :index
end

get '/memos/create' do
  erb :create
end

get '/memos/:id' do
  memos = get_memos
  @title = memos[params[:id]]['title']
  @content = memos[params[:id]]['content']
  erb :detail
end

post '/memos' do
  title = params[:title]
  content = params[:content]

  memos = get_memos

  max_key = memos.keys.map(&:to_i).max || 0
  id = (max_key + 1).to_i
  memos[id] = { 'title' => title, 'content' => content }
  set_memos(memos)

  redirect '/memos'
end

get '/memos/:id/edit' do
  memos = get_memos
  @title = memos[params[:id]]['title']
  @content = memos[params[:id]]['content']
  erb :edit
end

patch '/memos/:id' do
  title = params[:title]
  content = params[:content]

  memos = get_memos
  memos[params[:id]] = { 'title' => title, 'content' => content }
  set_memos(memos)

  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  memos = get_memos
  memos.delete(params[:id])
  set_memos(memos)

  redirect '/memos'
end
