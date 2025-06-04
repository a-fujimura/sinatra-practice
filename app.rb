# frozen_string_literal: true

require 'sinatra'
require 'json'

SAVE_FILE = 'memos.json'

get '/' do
  @memos = memos
  erb :index if @memos
end

get '/edit/:id' do
  @memo = get_memo(:id)
  erb :edit if @memo
end

get '/new' do
  erb :new
end

get '/show/:id' do
  @memo = get_memo(:id)
  erb :show if @memo
end

def memos
  read_json[:memos]
end

def get_memo(id)
  memos.find { |i| i[id] == params[id].to_i }
end

def add_memo(memo)
  memo_json = read_json
  value = memo_json[:autoincrement].to_i + 1

  memo[:id] = value

  memo_json[:autoincrement] = value
  memo_json[:memos] = memo_json[:memos] << memo

  write_json(memo_json)
end

def edit_memo(memo)
  memo_json = read_json

  target = memo_json[:memos].find { |x| x[:id] == memo[:id] }
  if target
    target[:title] = memo[:title]
    target[:content] = memo[:content]
  end

  write_json(memo_json)
end

def delete_memo(memo_id)
  memo_json = read_json

  memo_json[:memos]&.reject! { |x| x[:id].to_i == memo_id.to_i }

  write_json(memo_json)
end

# 取得(全てのアイテム)
get '/api/memos' do
  content_type :json
  get_memo.to_json
end

# 取得(指定のアイテム)
get '/api/memos/:id' do
  content_type :json
  memo = get_memo(:id)
  memo.to_json || { error: 'memo not fount' }.to_json
end

# 追加
post '/api/memos/add' do
  title = params[:title]
  content = params[:content]

  new_memo = {
    id: -1,
    title: title,
    content: content
  }
  add_memo(new_memo)

  redirect '/'
end

# 編集
patch '/api/memos/edit/:id' do
  memo = { id: params[:id].to_i, title: params[:title], content: params[:content] }
  edit_memo(memo)

  redirect '/'
end

# 削除
delete '/api/memos/delete/:id' do
  delete_memo(params[:id])
  redirect '/'
end

def write_json(memos)
  File.open(SAVE_FILE, 'w') do |file|
    file.write(JSON.pretty_generate(memos))
  end
end

def read_json
  write_json({ autoincrement: 0, memos: [] }) unless File.exist?(SAVE_FILE)
  # Jsonを取得
  JSON.parse(File.read(SAVE_FILE), symbolize_names: true)
end
