class Api::V1::RequestsController < ApplicationController
  def get_data
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @keyword = params[:keyword]

    @start_date_year = @start_date.split('-')[0]
    @start_date_month = @start_date.split('-')[1]
    @start_date_day = @start_date.split('-')[2]
    @start_datetime = Date.new(@start_date_year.to_i, @start_date_month.to_i, @start_date_day.to_i).to_time

    @end_date_year = @end_date.split('-')[0]
    @end_date_month = @end_date.split('-')[1]
    @end_date_day = @end_date.split('-')[2]
    @end_datetime = Date.new(@end_date_year.to_i, @end_date_month.to_i, @end_date_day.to_i).to_time

    @posts = Post.all.where(:date => @start_datetime.beginning_of_day..@end_datetime.beginning_of_day)
    @posts_needed = []
    @posts_to_send = []

    @comments = Comment.all.where(:date => @start_datetime.beginning_of_day..@end_datetime.beginning_of_day)
    @comments_needed = []
    @comments_to_send = []

    for post in @posts
      @post_arr = post.text.split(" ")
      @post_set = Set.new(@post_arr.map(&:downcase))
      if @post_set.include? @keyword.downcase
        @posts_needed.append({ date: post[:date], vector: post[:vector], text: post[:text], username: post[:user_username] })
      end
    end

    for comment in @comments
      @comment_arr = comment.text.split(" ")
      @comment_set = Set.new(@comment_arr.map(&:downcase))
      if @comment_set.include? @keyword.downcase
        @comments_needed.append({ date: comment[:date], vector: comment[:vector], text: comment[:text], username: comment[:owner_username] })
      end
    end

    @posts_to_send = @posts_needed.group_by{ |p| p[:date].to_date }
    @posts_to_send.sort_by { |date, posts| date }

    @comments_to_send = @comments_needed.group_by{ |p| p[:date].to_date }
    @comments_to_send.sort_by { |date, comments| date }

    # puts @posts_to_send
    puts @posts_to_send.length

    # puts @posts_to_send
    puts @comments_to_send.length

    data = {
      'posts': @posts_to_send,
      'comments': @comments_to_send,
    }

    render json: data
  end

  private

  def request_params
    params.permit(:source, :start_date, :end_date, :keyword)
  end
end
