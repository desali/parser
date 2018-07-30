# # coding: utf-8
#
# namespace :vk do
#     desc "Parsing Vkontakte!"
#
#     require 'date'
#     require "nokogiri"
#     require "open-uri"
#     require 'json'
#     require 'net/http'
#
#     # @root_url = "https://m.vk.com"
#     @ext_for_posts1 = "?offset="
#     @ext_for_posts2 = "&own=1"
#
#     @ext_for_user_info = '?act=info'
#
#     # Variables for test
#     @username_test =        'idxomyaaaaakk'
#     @user_id_test =         '1526059995'
#     @post_shortcode_test =  'BVIC06NA3Wv'
#     @group_test =           'typastana'
#
#     #VARIABLES FOR FULL PARSING
#
#
#     task :user_info => :environment do
#       @user = get_user_info(@username_test)
#     end
#
#     task :group_posts => :environment do
#       html = Nokogiri::HTML(open("#{root_url}"))
#       @posts_arr = []
#
#       html.css(".wall_item").each do |post|
#         @date = post.css('.wi_date')[0].text
#
#         if post.css(".pi_text")[0] != nil
#           @posts_arr.push(post.css(".pi_text")[0].text)
#           # puts post.css(".pi_text")[0].text
#           # Post.create(title: post.css(".pi_text")[0].text, source_id: 1, date: @date)
#         else
#           if post.css(".pi_text")[1] != nil
#             @posts_arr.push(post.css(".pi_text")[1].text)
#             # puts post.css(".pi_text")[1].text
#             # Post.create(title: post.css(".pi_text")[0].text, source_id: 1, date: @date)
#           else
#
#           end
#         end
#       end
#
#
#       if html.css(".slim_header_label").text == ""
#         @posts_count = html.css(".slim_header")[3].text.to_i
#       else
#         @posts_count = html.css(".slim_header_label").text.to_i
#       end
#
#       puts @posts_count
#
#       @cur_index = 5
#
#       loop do
#         puts "#{root_url}#{ext_for_posts1}#{@cur_index}#{ext_for_posts2}"
#
#         html = Nokogiri::HTML(open("#{root_url}#{ext_for_posts1}#{@cur_index}#{ext_for_posts2}"))
#
#         puts html.css(".wall_item").count
#
#         html.css(".wall_item").each do |post|
#           @date = post.css('.wi_date')[0].text
#
#           if post.css(".pi_text")[0] != nil
#             @posts_arr.push(post.css(".pi_text")[0].text)
#             # puts post.css(".pi_text")[0].text
#
#             puts post.css(".pi_text")[0].text
#             puts @date
#             Post.create(title: post.css(".pi_text")[0].text, source_id: 1, date: @date)
#           else
#             if post.css(".pi_text")[1] != nil
#               @posts_arr.push(post.css(".pi_text")[1].text)
#               # puts post.css(".pi_text")[1].text
#               Post.create(title: post.css(".pi_text")[0].text, source_id: 1, date: @date)
#             else
#
#             end
#           end
#         end
#
#         if @cur_index + 10 > 1000
#           break
#         else
#           @cur_index += 10
#         end
#       end
#
#       puts @posts_arr.count
#     end
#
#
#     def get_user_info(username)
#       html = Nokogiri::HTML(open("#{@root_url}/#{username}"))
#
#       @username = username
#       @fullname = html.css('.op_header').text
#       @address = html.css('.pp_info').text
#
#       @posts_count = 0
#
#       html.css(".slim_header_label").each do |info|
#         puts info
#         if info.text.include?("записей") || info.text.include?("записи")
#           @posts_count = info.text.to_i
#         end
#       end
#
#       html.css(".slim_header").each do |info|
#         puts info
#         if info.text.include?("записей") || info.text.include?("записи")
#           @posts_count = info.text.to_i
#         end
#       end
#
#       puts "Posts count is: #{@posts_count}"
#
#       html = Nokogiri::HTML(open("#{@root_url}/#{username}#{@ext_for_user_info}"))
#
#       html.css('._pinfo').each do |info|
#         if(info.css('dt').text == 'День рождения:')
#           @date = info.css('dd').text
#         end
#       end
#
#       puts "Fullname is: #{@fullname}"
#       puts "Username is: #{@username}"
#       puts "Address is: #{@address}"
#       puts "Birthday is: #{@date}"
#
#       return {
#         'username': @username,
#         'fullname': @fullname,
#         'posts_count': @posts_count
#       }
#     end
#
#     def get_user_posts(username)
#       html = Nokogiri::HTML(open("#{@root_url}/#{username}"))
#     end
#
#     def create_user(insta_id, username, fullname, biography, follower_count, following_count)
#       @user = User.new(source_id: 1, insta_id: insta_id, username: username, fullname: fullname, biography: biography, follower_count: follower_count, following_count: following_count)
#       if @user.save
#         puts "User created!"
#         puts @user
#
#         return true
#       else
#         puts "Error occured while creating user!"
#         puts @user.errors.full_messages
#
#         return false
#       end
#     end
#
#     def create_post(user_id, insta_id, shortcode, text, date, vector)
#       @post = Post.new(user_id: user_id, insta_id: insta_id, shortcode: shortcode, text: text, date: date, vector: vector)
#       if @post.save
#         puts "Post created!"
#         puts @post
#
#         return true
#       else
#         puts "Error occured while creating post!"
#         puts @post.errors.full_messages
#
#         return false
#       end
#     end
#
#     def create_comment(post_id, owner_id, owner_username, insta_id, text, date, vector)
#       @comment = Comment.new(post_id: post_id, owner_id: owner_id, owner_username: owner_username, insta_id: insta_id, text: text, date: date, vector: vector)
#       if @comment.save
#         puts "Comment created!"
#         puts @comment
#       else
#         puts "Error occured while creating comment!"
#         puts @comment.errors.full_messages
#       end
#     end
#
#
#     def send_data(data)
#       @uri = URI('http://127.0.0.1:5000/vectorize')
#       @http = Net::HTTP.new(@uri.host, @uri.port)
#       @request = Net::HTTP::Post.new(@uri.path, {'Content-Type' => 'application/json'})
#       @request.body = data.to_json
#
#       @response = @http.request(@request)
#       return @response.body
#     end
# end
