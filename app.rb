require "sinatra"
require_relative "./models.rb"
require_relative "api_authentication.rb"

get "/secret" do
	api_authenticate!
	halt 200, {message: "This message is super confidential. I like wings. and beer too."}.to_json
end

#CREATE
#POST /todo_items?text=take out the trash
post "/todo_items" do
	api_authenticate!

	t = TodoItem.new
	t.text = params["text"]
	t.user_id = current_user.id
	t.save

	halt 201, t.to_json
end

#READ
get "/todo_items" do
	api_authenticate!
	items = TodoItem.all(user_id: current_user.id)
	halt 200, items.to_json
end

#UPDATE
#PATCH /todo_items/1?completed=true
#PATCH /todo_items/1?completed=false
#PATCH /todo_items/1?text=take out the trash
patch "/todo_items/:id" do
	api_authenticate!

	item = Item.get(params["id"])
	if item != nil
		
		if item.user_id == current_user.id
			if params["text"]
				item.text = params["text"]
			end
	
			if params["completed"]
				if params["completed"]=="true"
					item.completed = true
				end
	
				if params["completed"]=="false"
					item.completed = false
				end
			end
	
			item.save
			halt 200, item.to_json
		else
			halt 401, {message: "Unauthorized"}.to_json
		end
	else
		halt 404, {message: "Item not found"}.to_json
	end
end


#DESTROY
#DELETE /todo_items/1
delete "/todo_items/:id" do
	api_authenticate!
	item = Item.get(params["id"])

	if item != nil
		if item.user_id == current_user.id
			item.destroy
			halt 200, {message: "Item has been deleted"}.to_json
		else
			halt 401, {message: "Unauthorized"}.to_json
		end
	else
		halt 404, {message: "Item not found"}.to_json
	end
end