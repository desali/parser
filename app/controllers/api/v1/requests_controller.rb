class Api::V1::RequestsController < ApplicationController
  def get_data
    @source_id = Source.all.where(title: params[:source])
    @posts = Post.all.where(source_id: @source_id)
    @posts_needed = []

    for post in @posts
      if post.title.include? params[:keyword]
        @posts_needed.append(post)
      end
    end

    puts @posts_needed.length

    render json: @posts_needed
  end

  private

  def request_params
    params.permit(:source, :start_date, :end_date, :keyword)
  end
end
