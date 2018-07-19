class PostsController < ApplicationController
	def posts_json
		data = Post.all.to_json
		send_data data, :type => 'application/json; header=present', :disposition => "attachment; filename=posts.json"
	end
end
