# frozen_string_literal: true

require 'sinatra'
require 'json'
set :erb, escape_html: true

SAVE_FILE = 'memos.json'

get '/memos' do
  @memos = memos || []
  erb :index
end

def memos
  read_json[:memos]
end

get '/memos/show/:id' do
  @memo = get_memo(params[:id])
  erb :show
end

get '/memos/edit/:id' do
  @memo = get_memo(params[:id])
  erb :edit
end

def get_memo(id)
  memos[id.to_sym]
end

get '/memos/new' do
  erb :new
end

post '/api/memos' do
  new_memo = {
    title: params[:title],
    content: params[:content]
  }
  add_memo(new_memo)

  redirect '/memos'
end

def add_memo(data)
  memo_json = read_json
  new_id = memo_json[:autoincrement].to_i + 1

  memo_json[:autoincrement] = new_id
  memo_json[:memos][new_id] = data

  write_json(memo_json)
end

patch '/api/memos/:id' do
  memo = { title: params[:title], content: params[:content] }
  edit_memo(params[:id], memo)

  redirect '/memos'
end

def edit_memo(id, data)
  memo_json = read_json
  target = memo_json[:memos][id.to_sym]
  if target
    target[:title] = data[:title]
    target[:content] = data[:content]
  end
  write_json(memo_json)
end

def write_json(data)
  File.open(SAVE_FILE, 'w') do |file|
    file.write(JSON.pretty_generate(data))
  end
end

delete '/api/memos/:id' do
  delete_memo(params[:id])
  redirect '/memos'
end

def delete_memo(id)
  memo_json = read_json
  memo_json[:memos].delete(id.to_sym)

  write_json(memo_json)
end

def read_json
  write_json({ autoincrement: 0, memos: {} }) unless File.exist?(SAVE_FILE)
  JSON.parse(File.read(SAVE_FILE), symbolize_names: true)
end
