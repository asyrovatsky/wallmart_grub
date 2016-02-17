json.array!(@searches) do |search|
  json.extract! search, :id, :product_id, :text
  json.url search_url(search, format: :json)
end
