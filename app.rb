# frozen_string_literal: true

require 'sinatra'
require 'json'
set :erb, escape_html: true

SAVE_FILE = 'memos.json'

get '/memos' do
  @memos = memos || []
  erb :index if @memos
end

get '/memos/:id/edit' do
  @memo = get_memo(params[:id])
  erb :edit if @memo
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  @memo = get_memo(params[:id])
  erb :show if @memo
end

def memos
  read_json[:memos]
end

def get_memo(memo_id)
  memos[memo_id.to_sym]
end

def add_memo(memo_content)
  memo_json = read_json
  new_id = memo_json[:autoincrement].to_i + 1

  memo_json[:autoincrement] = new_id
  memo_json[:memos][new_id] = memo_content

  write_json(memo_json)
end

def edit_memo(memo_key, memo_content)
  memo_json = read_json
  target = memo_json[:memos][memo_key.to_sym]
  if target
    target[:title] = memo_content[:title]
    target[:content] = memo_content[:content]
  end
  write_json(memo_json)
end

def delete_memo(memo_key)
  memo_json = read_json
  memo_json[:memos].delete(memo_key.to_sym)

  write_json(memo_json)
end

post '/api/memos' do
  new_memo = {
    title: params[:title],
    content: params[:content]
  }
  add_memo(new_memo)

  redirect '/memos'
end

patch '/api/memos/:id' do
  memo = { title: params[:title], content: params[:content] }
  edit_memo(params[:id], memo)

  redirect '/memos'
end

delete '/api/memos/:id' do
  delete_memo(params[:id])
  redirect '/memos'
end

def write_json(memos)
  File.open(SAVE_FILE, 'w') do |file|
    file.write(JSON.pretty_generate(memos))
  end
end

def read_json
  write_json({ autoincrement: 0, memos: {} }) unless File.exist?(SAVE_FILE)
  JSON.parse(File.read(SAVE_FILE), symbolize_names: true)
end
