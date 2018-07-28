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

    for post in @posts
      if post.text.include? @keyword
        @posts_needed.append({ date: post[:date], vector: post[:vector] })
      end
    end

    @posts_to_send = @posts_needed.group_by{ |p| p[:date].to_date }

    puts @posts_to_send
    puts @posts_to_send.length

    render json: @posts_to_send
  end

  private

  def request_params
    params.permit(:source, :start_date, :end_date, :keyword)
  end
end
