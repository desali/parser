#coding: utf-8

namespace :insta do
    desc "Parsing!"
    @root_url = "https://www.instagram.com"
    @ext_for_user = "/marple"
    @ext_for_post = "/p/BlV7hgSlv87/?taken-by=ronaldo"
    @ext_for_posts = "/graphql/query"

    task :user_info => :environment do
      require "nokogiri"
      require "open-uri"
      require 'json'

      html = Nokogiri::HTML(open("#{@root_url}#{@ext_for_user}"), nil, 'UTF-8')

      html.css('script').each do |script|
        if script.text.include?("window._sharedData =")
          @data_json = JSON.parse(script.text[21..-2])
        end

      end

      @user = @data_json["entry_data"]["ProfilePage"][0]["graphql"]["user"]

      @id = @user["id"]
      @username = @user["username"]
      @fullname = @user["full_name"]
      @biography = @user["biography"]
      @follower_count = @user["edge_followed_by"]["count"]
      @following_count = @user["edge_follow"]["count"]
      @posts_count = @user["edge_owner_to_timeline_media"]["count"]

      puts "User id: #{@id}"
      puts "User username: #{@username}"
      puts "User fullname: #{@fullname}"
      puts "User biography: #{@biography}"
      puts "User follower count: #{@follower_count}"
      puts "User following count: #{@following_count}"
      puts "User posts count: #{@posts_count}"
    end

    task :user_posts => :environment do
      require "nokogiri"
      require "open-uri"
      require 'json'

      html = Nokogiri::HTML(open("#{@root_url}#{@ext_for_user}"), nil, 'UTF-8')

      html.css('script').each do |script|
        if script.text.include?("window._sharedData =")
          @data_json = JSON.parse(script.text[21..-2])
        end
      end

      @user = @data_json["entry_data"]["ProfilePage"][0]["graphql"]["user"]

      @media = @user["edge_owner_to_timeline_media"]
      @posts_count = @media["count"]
      @posts = @media["edges"]

      puts "User posts count: #{@posts_count}"
      puts "User posts have: #{@posts.count}"
      puts ""

      @index = 1
      @posts.each do |post|
        @post_body = post["node"]
        @id = @post_body["id"]
        @text = @post_body["edge_media_to_caption"]["edges"][0]["node"]["text"]
        @shortcode = @post_body["shortcode"]
        @comments_count = @post_body["edge_media_to_comment"]["count"]
        @likes_count = @post_body["edge_liked_by"]["count"]

        puts "#{@index} post:"
        puts "Post id: #{@id}"
        puts "Post text: #{@text}"
        puts "Post comments count: #{@comments_count}"
        puts "Post likes count: #{@likes_count}"
        puts "Post shortcode: #{@shortcode}"
        puts ""

        @index += 1
      end
    end

    task :user_posts_all => :environment do
      require "nokogiri"
      require "open-uri"
      require 'json'

      html = Nokogiri::HTML(open("#{@root_url}#{@ext_for_user}"), nil, 'UTF-8')

      html.css('script').each do |script|
        if script.text.include?("window._sharedData =")
          @data_json = JSON.parse(script.text[21..-2])
        end
      end

      @user = @data_json["entry_data"]["ProfilePage"][0]["graphql"]["user"]
      @user_id = @user["id"]

      @media = @user["edge_owner_to_timeline_media"]
      @cursor = @media["page_info"]["end_cursor"]

      @posts_count = @media["count"]
      @posts = @media["edges"]

      puts "User posts count: #{@posts_count}"
      puts "User posts have: #{@posts.count}"
      puts ""

      @index = 1
      @posts.each do |post|
        @post_body = post["node"]
        @id = @post_body["id"]
        @text = @post_body["edge_media_to_caption"]["edges"][0]["node"]["text"]
        @shortcode = @post_body["shortcode"]
        @comments_count = @post_body["edge_media_to_comment"]["count"]
        @likes_count = @post_body["edge_liked_by"]["count"]

        puts "#{@index} post:"
        puts "Post id: #{@id}"
        puts "Post text: #{@text}"
        puts "Post comments count: #{@comments_count}"
        puts "Post likes count: #{@likes_count}"
        puts "Post shortcode: #{@shortcode}"
        puts ""

        @index += 1
      end

      @query_hash = "bd0d6d184eefd4d0ce7036c11ae58ed9"
      @cookie = 'csrftoken=rX4tiOGNFc1ZpYswnNZAI4UVOqiG4uRI; shbid=19224; ds_user_id=6133659914; rur=FRC; mcd=3; mid=W08PCgAEAAFKNyDVUc179t05LfnL; sessionid=IGSCa5337e0cd67a8bf986c4cc082ce590f9bc406c36d67a631379090dcb1bd27c2d%3ADpwNePeQuXtqT6aPkSya19fQpQtjWbBq%3A%7B%22_auth_user_id%22%3A6133659914%2C%22_auth_user_backend%22%3A%22accounts.backends.CaseInsensitiveModelBackend%22%2C%22_auth_user_hash%22%3A%22%22%2C%22_platform%22%3A4%2C%22_token_ver%22%3A2%2C%22_token%22%3A%226133659914%3AcIwPJSmI2D6NJJ7QyIvNHKeBBywTDKyP%3A3e380aeb4436c65903f034746bbc27f95bd19e67cf64f8955a1112c5523aae53%22%2C%22last_refreshed%22%3A1531933905.6709194183%7D; urlgen="{\"time\": 1531907850}:1ffrVN:uXPzY5vXYbjGXmA18RLqlfT9C58"'

      while @media["page_info"]["has_next_page"]
        @variables = '{"id":' + "\"#{@user_id}\"" + ',"first":12,"after":' + "\"#{@cursor}\"" + '}'
        @url = "#{@root_url}#{@ext_for_posts}?query_hash=#{@query_hash}&variables=#{@variables}"
        puts @url

        html = Nokogiri::HTML(open("#{@url}", "Cookie" => "#{@cookie}"), nil, 'UTF-8')

        @data_json = JSON.parse(html)

        @user = @data_json["data"]["user"]
        @media = @user["edge_owner_to_timeline_media"]
        @cursor = @media["page_info"]["end_cursor"]
        @posts_count = @media["count"]
        @posts = @media["edges"]

        puts "User posts count: #{@posts_count}"
        puts "User posts have: #{@posts.count}"
        puts ""

        @posts.each do |post|
          @post_body = post["node"]
          @id = @post_body["id"]
          @text = @post_body["edge_media_to_caption"]["edges"][0]["node"]["text"]
          @shortcode = @post_body["shortcode"]
          @comments_count = @post_body["edge_media_to_comment"]["count"]
          @likes_count = @post_body["edge_media_preview_like"]["count"]

          puts "#{@index} post:"
          puts "Post id: #{@id}"
          puts "Post text: #{@text}"
          puts "Post comments count: #{@comments_count}"
          puts "Post likes count: #{@likes_count}"
          puts "Post shortcode: #{@shortcode}"
          puts ""

          @index += 1
        end
      end
    end

    task :post_comments => :environment do
      require "nokogiri"
      require "open-uri"
      require 'json'

      html = Nokogiri::HTML(open("#{@root_url}#{@ext_for_post}"), nil, 'UTF-8')

      html.css('script').each do |script|
        if script.text.include?("window._sharedData =")
          @data_json = JSON.parse(script.text[21..-2])
        end
      end

      @post = @data_json["entry_data"]["PostPage"][0]["graphql"]["shortcode_media"]

      @id = @post["id"]
      @shortcode = @post["shortcode"]
      @text = @post["edge_media_to_caption"]["edges"][0]["node"]["text"]

      @media = @post["edge_media_to_comment"]
      @comments_count = @media["count"]
      @comments = @media["edges"]

      puts "Post comments count: #{@comments_count}"
      puts "Post comments have: #{@comments.count}"
      puts ""

      @index = 1
      @comments.each do |comment|
        @comment_body = comment["node"]
        @id = @comment_body["id"]
        @text = @comment_body["text"]

        @owner = @comment_body["owner"]
        @owner_id = @owner["id"]
        @owner_username = @owner["username"]

        @likes_count = @comment_body["edge_liked_by"]["count"]

        puts "#{@index} comment:"
        puts "Comment id: #{@id}"
        puts "Comment text: #{@text}"
        puts "Comment owner id: #{@owner_id}"
        puts "Comment owner username: #{@owner_username}"
        puts "Comment likes count: #{@likes_count}"
        puts ""

        @index += 1
      end
    end

    task :post_comments_all => :environment do
      require "nokogiri"
      require "open-uri"
      require 'json'

      html = Nokogiri::HTML(open("#{@root_url}#{@ext_for_post}"), nil, 'UTF-8')

      html.css('script').each do |script|
        if script.text.include?("window._sharedData =")
          @data_json = JSON.parse(script.text[21..-2])
        end
      end

      @post = @data_json["entry_data"]["PostPage"][0]["graphql"]["shortcode_media"]

      @id = @post["id"]
      @shortcode = @post["shortcode"]
      @text = @post["edge_media_to_caption"]["edges"][0]["node"]["text"]

      @media = @post["edge_media_to_comment"]
      @cursor = @media["page_info"]["end_cursor"]

      @comments_count = @media["count"]
      @comments = @media["edges"]

      puts "Post comments count: #{@comments_count}"
      puts "Post comments have: #{@comments.count}"
      puts ""

      @index = 1
      @comments.each do |comment|
        @comment_body = comment["node"]
        @id = @comment_body["id"]
        @text = @comment_body["text"]

        @owner = @comment_body["owner"]
        @owner_id = @owner["id"]
        @owner_username = @owner["username"]

        @likes_count = @comment_body["edge_liked_by"]["count"]

        puts "#{@index} comment:"
        puts "Comment id: #{@id}"
        puts "Comment text: #{@text}"
        puts "Comment owner id: #{@owner_id}"
        puts "Comment owner username: #{@owner_username}"
        puts "Comment likes count: #{@likes_count}"
        puts ""

        @index += 1
      end

      @query_hash = "f0986789a5c5d17c2400faebf16efd0d"
      @cookie = 'csrftoken=rX4tiOGNFc1ZpYswnNZAI4UVOqiG4uRI; shbid=19224; ds_user_id=6133659914; rur=FRC; mcd=3; mid=W08PCgAEAAFKNyDVUc179t05LfnL; sessionid=IGSCa5337e0cd67a8bf986c4cc082ce590f9bc406c36d67a631379090dcb1bd27c2d%3ADpwNePeQuXtqT6aPkSya19fQpQtjWbBq%3A%7B%22_auth_user_id%22%3A6133659914%2C%22_auth_user_backend%22%3A%22accounts.backends.CaseInsensitiveModelBackend%22%2C%22_auth_user_hash%22%3A%22%22%2C%22_platform%22%3A4%2C%22_token_ver%22%3A2%2C%22_token%22%3A%226133659914%3AcIwPJSmI2D6NJJ7QyIvNHKeBBywTDKyP%3A3e380aeb4436c65903f034746bbc27f95bd19e67cf64f8955a1112c5523aae53%22%2C%22last_refreshed%22%3A1531933905.6709194183%7D; urlgen="{\"time\": 1531907850}:1ffrVN:uXPzY5vXYbjGXmA18RLqlfT9C58"'

      while @media["page_info"]["has_next_page"]
        @variables = '{"shortcode":' + "\"#{@shortcode}\"" + ',"first":35,"after":' + "\"#{@cursor}\"" + '}'
        @url = "#{@root_url}#{@ext_for_posts}?query_hash=#{@query_hash}&variables=#{@variables}"
        puts @url

        html = Nokogiri::HTML(open("#{@url}", "Cookie" => "#{@cookie}"), nil, 'UTF-8')

        @data_json = JSON.parse(html)

        @media = @data_json["data"]["shortcode_media"]["edge_media_to_comment"]

        @cursor = @media["page_info"]["end_cursor"]
        @comments_count = @media["count"]
        @comments = @media["edges"]

        puts "Post comments count: #{@comments_count}"
        puts "Post comments have: #{@comments.count}"
        puts ""

        @comments.each do |comment|
          @comment_body = comment["node"]
          @id = @comment_body["id"]
          @text = @comment_body["text"]

          @owner = @comment_body["owner"]
          @owner_id = @owner["id"]
          @owner_username = @owner["username"]

          @likes_count = @comment_body["edge_liked_by"]["count"]

          puts "#{@index} comment:"
          puts "Comment id: #{@id}"
          puts "Comment text: #{@text}"
          puts "Comment owner id: #{@owner_id}"
          puts "Comment owner username: #{@owner_username}"
          puts "Comment likes count: #{@likes_count}"
          puts ""

          @index += 1
        end
      end
    end

    task :export => :environment do
      Rails.application.eager_load!

      file = File.open(File.join(Rails.root, "db", "export", "posts.json"), 'w')
      file.write Post.all.to_json
      file.close
    end
end
