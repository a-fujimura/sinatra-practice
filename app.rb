require "sinatra"
require "json"

$save_file = "items.json"

get "/" do
  @items = get_items()
  if @items
    erb :index
  else
  end
end

get "/edit/:id" do
  @item = get_item(:id)
  if @item
    erb :edit
  else
  end
end

get "/new" do
  erb :new
end

get "/show/:id" do
  @item = get_item(:id)
  if @item
    erb :show
  else
  end
end

def get_app_db()
  return read_json()
end

def set_app_db(app_data)
  write_json(items)
end

def get_items()
  return get_app_db()[:items]
end

def get_item(id)
  return get_items().find { |i| i[:id] == params[:id].to_i }
end

def add_item(item)
  app_db = get_app_db()
  value = app_db[:autoincrement].to_i + 1

  item[:id] = value

  app_db[:autoincrement] = value
  app_db[:items] = app_db[:items] << item

  write_json(app_db)
end

def edit_item(item)
  app_db = get_app_db()

  target = app_db[:items].find { |x| x[:id] == item[:id] }
  if target
    target[:title] = item[:title]
    target[:content] = item[:content]
  end

  write_json(app_db)
end

def delete_item(item_id)
  app_db = get_app_db()

  if app_db[:items]
    app_db[:items].reject! { |x| x[:id].to_i == item_id.to_i }
  end

  write_json(app_db)
end

# 取得(全てのアイテム)
get "/api/items" do
  content_type :json
  get_item.to_json
end

# 取得(指定のアイテム)
get "/api/items/:id" do
  content_type :json
  item = get_item(:id)
  if item.to_json
    item.to_json
  else
    { error: "Item not fount" }.to_json
  end
end

# 追加
post "/api/items/add" do
  title = params[:title]
  content = params[:content]

  new_item = {
    id: -1,
    title: title,
    content: content,
  }
  add_item(new_item)

  redirect "/"
end

# 編集
patch "/api/items/edit/:id" do
  item = { id: params[:id].to_i, title: params[:title], content: params[:content] }
  edit_item(item)

  redirect "/"
end

# 削除
delete "/api/items/delete/:id" do
  delete_item(params[:id])
  redirect "/"
end

def write_json(items)
  File.open($save_file, "w") do |file|
    file.write(JSON.pretty_generate(items))
  end
end

def read_json()
  unless File.exist?($save_file)
    write_json({ autoincrement: 0, items: [] })
  end
  # Jsonを取得
  items = JSON.parse(File.read($save_file), symbolize_names: true)
  return items
end
