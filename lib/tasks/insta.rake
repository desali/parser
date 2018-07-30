# coding: utf-8

namespace :insta do
    desc "Parsing Instagram!"

    require 'date'
    require "nokogiri"
    require "open-uri"
    require 'json'
    require 'net/http'

    @root_url = "https://www.instagram.com"
    @ext_for_query = "/graphql/query"
    @ext_for_tags = "/explore/tags/"
    @ext_for_post0 = "/p/"
    @ext_for_comments1  = "/p/"
    @ext_for_comments2  = "/?taken-by="

    # Variables for test
    @username_test =        'ddagar'
    @user_id_test =         '1526059995'
    @post_shortcode_test =  'BVIC06NA3Wv'
    @tag_test =             'tengrinews'

    #VARIABLES FOR FULL PARSING
    @tag_full = 'астанасити❤️'

    task :parse_full_test => :environment do
      # require 'parallel'
      start_time = Time.now

      @users_with_shortcode = get_users_with_tag(@tag_full)

      # puts @users_with_shortcode

      @users_with_shortcode.each do |user|
        @shortcode = user[:post_shortcode]
        @user = get_user(@shortcode)

        @user_username = @user[:username]
        @user_full_info = get_user_info(@user_username)

        # Create User with full info
        if create_user(@user_full_info[:id], @user_full_info[:username], @user_full_info[:fullname], @user_full_info[:biography], @user_full_info[:follower_count], @user_full_info[:following_count])
          @posts = get_user_posts(@user_username)

          @vectors_str = send_data(@posts)
          @post_vectors = @vectors_str.split(',')

          # Send all posts to ml server
          # Then with response of vectors create posts
          send_data(@posts)

          for post_index in (0...@posts.length) do
            if create_post(@user_full_info[:id], @posts[post_index][:user_username], @posts[post_index][:id], @posts[post_index][:shortcode], @posts[post_index][:text], @posts[post_index][:date], @post_vectors[post_index])
              @comments = get_post_comments(@user_full_info[:username], @posts[post_index][:shortcode])
              # Send all comments to ml server
              # Then with response of vectors create comments

              @vectors_str = send_data(@comments)
              @comment_vectors = @vectors_str.split(',')

              for comment_index in (0...@comments.length) do
                create_comment(@posts[post_index][:id], @comments[comment_index][:owner_id], @comments[comment_index][:owner_username], @comments[comment_index][:id], @comments[comment_index][:text], @comments[comment_index][:date], @comment_vectors[comment_index])
              end
            end
          end

          # @friends = get_user_friends(@user_full_info[:id])
          #
          # @friends.each do |friend|
          #   @friend_username = friend[:username]
          #   @friend_full_info = get_user_info(@friend_username)
          #   # Create User with full info
          #
          #   # Create User with full info
          #   if create_user(@friend_full_info[:id], @friend_full_info[:username], @friend_full_info[:fullname], @friend_full_info[:biography], @friend_full_info[:follower_count], @friend_full_info[:following_count])
          #     @posts = get_user_posts(@friend_username)
          #
          #     # Send all posts to ml server
          #     # Then with response of vectors create posts
          #
          #     @posts.each do |post|
          #       if create_post(@friend_full_info[:id], post[:id], post[:shortcode], post[:text], post[:date])
          #         @comments = get_post_comments(@friend_full_info[:username], post[:shortcode])
          #         # Send all comments to ml server
          #         # Then with response of vectors create comments
          #
          #         @comments.each do |comment|
          #           create_comment(post[:id], comment[:owner_id], comment[:owner_username], comment[:id], comment[:text], comment[:date])
          #         end
          #       end
          #     end
          #   end
          # end
        end
      end

      end_time = Time.now

      puts end_time - start_time
    end

    task :user_friends => :environment do
      @friends = get_user_friends(@user_id_test)

      puts @friends
      puts @friends.length
    end

    task :location => :environment do
      @users = get_users_with_tag(@tag_test)

      puts @users
      puts @users.length
    end

    task :user_info => :environment do
      @user = get_user_info(@username_test)

      puts @user
    end

    task :user_posts_all => :environment do
      @posts = get_user_posts(@username_test)

      puts @posts
      puts @posts.length

      # File.open("public/test_posts.json","w") do |f|
      #   f.write(@posts.to_json)
      # end
    end

    task :post_comments_all => :environment do
      @comments = get_post_comments(@username_test, @post_shortcode_test)

      puts @comments
      puts @comments.length
    end

    task :test => :environment do
      @cookie = 'csrftoken=rX4tiOGNFc1ZpYswnNZAI4UVOqiG4uRI; shbid=19224; ds_user_id=6133659914; mid=W1cFUgAEAAGWZns_pZuLYPe7jiD5; sessionid=IGSCf9c84d0280cd7fc601736ef4a399c7b0587a225a00d7b3dad90e33bac4695ae1%3As0Bjd7QkLDhxBmgF1L1fblZFg1pI4ADa%3A%7B%22_auth_user_id%22%3A6133659914%2C%22_auth_user_backend%22%3A%22accounts.backends.CaseInsensitiveModelBackend%22%2C%22_auth_user_hash%22%3A%22%22%2C%22_platform%22%3A4%2C%22_token_ver%22%3A2%2C%22_token%22%3A%226133659914%3AcIwPJSmI2D6NJJ7QyIvNHKeBBywTDKyP%3A3e380aeb4436c65903f034746bbc27f95bd19e67cf64f8955a1112c5523aae53%22%2C%22last_refreshed%22%3A1532429650.2432715893%7D; rur=FRC; fbm_124024574287414="base_domain=.instagram.com"; mcd=3; ig_cb=1; shbts=1532450692.7065768; urlgen="{\"time\": 1532449387}:1fi0Ql:w8HnCt8BS-pbuAXBPuyNn_Pkfnk"'
      @url = 'https://www.instagram.com/graphql/query?query_hash=ded47faa9a1aaded10161a2ff32abb6b&variables={"tag_name":"tengrinews","first":1000,"after":"AQDjSJb0bgqDuXxickUPzi6pS4WNUsX9otk547JezHtGw6ZNA2CJBYg66-FimIc0g4JNAci524Vw17HPvXAtwU8HdV7-1c177xjpxgkTzIZECA"}'

      html = Nokogiri::HTML(open(URI.encode("#{@url}"), "Cookie" => "#{@cookie}"), nil, 'UTF-8')

      @has_next_page_start_id = html.to_s.index('has_next_page":') + 15
      @has_next_page_end_id = html.to_s.index(',', @has_next_page_start_id) - 1

      @end_cursor_start_id = html.to_s.index('end_cursor":"') + 13
      @end_cursor_end_id = html.to_s.index('"', @end_cursor_start_id) - 1

      puts html.to_s[@has_next_page_start_id..@has_next_page_end_id]
      puts html.to_s[@end_cursor_start_id..@end_cursor_end_id]
    end

    task :export => :environment do
      Rails.application.eager_load!

      file = File.open(File.join(Rails.root, "db", "export", "posts.json"), 'w')
      file.write Post.all.to_json
      file.close
    end


    def get_user(shortcode)
      @url = "#{@root_url}#{@ext_for_post0}#{shortcode}"

      html = Nokogiri::HTML(open("#{@url}"), nil, 'UTF-8')

      html.css('script').each do |script|
        if script.text.include?("window._sharedData =")
          @data_json = JSON.parse(script.text[21..-2])
        end
      end

      @post = @data_json["entry_data"]["PostPage"][0]["graphql"]["shortcode_media"]
      @owner = @post["owner"]

      return {
        'username': @owner["username"]
      }
    end

    def get_user_info(username)
      html = Nokogiri::HTML(open("#{@root_url}/#{username}"), nil, 'UTF-8')

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

      return {
        'id': @id,
        'username': @username,
        'fullname': @fullname,
        'biography': @biography,
        'follower_count': @follower_count,
        'following_count': @following_count,
        'posts_count': @posts_count
      }
    end

    def get_user_posts(username)
      @query_hash = "bd0d6d184eefd4d0ce7036c11ae58ed9"
      @cookie = 'csrftoken=rX4tiOGNFc1ZpYswnNZAI4UVOqiG4uRI; shbid=19224; ds_user_id=6133659914; rur=FRC; mcd=3; mid=W08PCgAEAAFKNyDVUc179t05LfnL; sessionid=IGSCa5337e0cd67a8bf986c4cc082ce590f9bc406c36d67a631379090dcb1bd27c2d%3ADpwNePeQuXtqT6aPkSya19fQpQtjWbBq%3A%7B%22_auth_user_id%22%3A6133659914%2C%22_auth_user_backend%22%3A%22accounts.backends.CaseInsensitiveModelBackend%22%2C%22_auth_user_hash%22%3A%22%22%2C%22_platform%22%3A4%2C%22_token_ver%22%3A2%2C%22_token%22%3A%226133659914%3AcIwPJSmI2D6NJJ7QyIvNHKeBBywTDKyP%3A3e380aeb4436c65903f034746bbc27f95bd19e67cf64f8955a1112c5523aae53%22%2C%22last_refreshed%22%3A1531933905.6709194183%7D; urlgen="{\"time\": 1531907850}:1ffrVN:uXPzY5vXYbjGXmA18RLqlfT9C58"'

      @posts_json = []

      html = Nokogiri::HTML(open("#{@root_url}/#{username}"), nil, 'UTF-8')

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

      @index = 1
      @posts.each do |post|
        @post_body = post["node"]
        @id = @post_body["id"]
        if @post_body["edge_media_to_caption"]["edges"] != []
          @text = @post_body["edge_media_to_caption"]["edges"][0]["node"]["text"]
        end
        @shortcode = @post_body["shortcode"]
        @date = Time.at(@post_body["taken_at_timestamp"]).to_datetime
        @comments_count = @post_body["edge_media_to_comment"]["count"]
        @likes_count = @post_body["edge_liked_by"]["count"]

        @posts_json.append({
          'id': @id,
          'user_username': username,
          'shortcode': @shortcode,
          'text': @text,
          'date': @date,
          'comments_count': @comments_count,
          'likes_count': @likes_count
        })

        @index += 1
      end


      while @media["page_info"]["has_next_page"]

        @variables = '{"id":' + "\"#{@user_id}\"" + ',"first":1000,"after":' + "\"#{@cursor}\"" + '}'
        @url = "#{@root_url}#{@ext_for_query}?query_hash=#{@query_hash}&variables=#{@variables}"

        html = Nokogiri::HTML(open("#{@url}", "Cookie" => "#{@cookie}"), nil, 'UTF-8')

        @data_json = JSON.parse(html)

        @user = @data_json["data"]["user"]
        @media = @user["edge_owner_to_timeline_media"]
        @cursor = @media["page_info"]["end_cursor"]
        @posts_count = @media["count"]
        @posts = @media["edges"]

        @posts.each do |post|
          @post_body = post["node"]
          @id = @post_body["id"]
          if @post_body["edge_media_to_caption"]["edges"] != []
            @text = @post_body["edge_media_to_caption"]["edges"][0]["node"]["text"]
          end
          @shortcode = @post_body["shortcode"]
          @date = Time.at(@post_body["taken_at_timestamp"]).to_datetime
          @comments_count = @post_body["edge_media_to_comment"]["count"]
          @likes_count = @post_body["edge_media_preview_like"]["count"]

          @posts_json.append({
            'id': @id,
            'shortcode': @shortcode,
            'text': @text,
            'date': @date,
            'comments_count': @comments_count,
            'likes_count': @likes_count
          })

          @index += 1
        end
      end

      return @posts_json
    end

    def get_post_comments(username, post_shortcode)
      @query_hash = "f0986789a5c5d17c2400faebf16efd0d"
      @cookie = 'csrftoken=rX4tiOGNFc1ZpYswnNZAI4UVOqiG4uRI; shbid=19224; ds_user_id=6133659914; rur=FRC; mcd=3; mid=W08PCgAEAAFKNyDVUc179t05LfnL; sessionid=IGSCa5337e0cd67a8bf986c4cc082ce590f9bc406c36d67a631379090dcb1bd27c2d%3ADpwNePeQuXtqT6aPkSya19fQpQtjWbBq%3A%7B%22_auth_user_id%22%3A6133659914%2C%22_auth_user_backend%22%3A%22accounts.backends.CaseInsensitiveModelBackend%22%2C%22_auth_user_hash%22%3A%22%22%2C%22_platform%22%3A4%2C%22_token_ver%22%3A2%2C%22_token%22%3A%226133659914%3AcIwPJSmI2D6NJJ7QyIvNHKeBBywTDKyP%3A3e380aeb4436c65903f034746bbc27f95bd19e67cf64f8955a1112c5523aae53%22%2C%22last_refreshed%22%3A1531933905.6709194183%7D; urlgen="{\"time\": 1531907850}:1ffrVN:uXPzY5vXYbjGXmA18RLqlfT9C58"'

      @comments_json = []

      html = Nokogiri::HTML(open("#{@root_url}#{@ext_for_comments1}#{post_shortcode}#{@ext_for_comments2}#{username}"), nil, 'UTF-8')

      html.css('script').each do |script|
        if script.text.include?("window._sharedData =")
          @data_json = JSON.parse(script.text[21..-2])
        end
      end

      @post = @data_json["entry_data"]["PostPage"][0]["graphql"]["shortcode_media"]

      @id = @post["id"]
      @shortcode = @post["shortcode"]
      if @post_body["edge_media_to_caption"]["edges"] != []
        @text = @post_body["edge_media_to_caption"]["edges"][0]["node"]["text"]
      end

      @media = @post["edge_media_to_comment"]
      @cursor = @media["page_info"]["end_cursor"]

      @comments_count = @media["count"]
      @comments = @media["edges"]

      @index = 1
      @comments.each do |comment|
        @comment_body = comment["node"]

        @id = @comment_body["id"]
        @date = Time.at(@comment_body["created_at"]).to_datetime
        @text = @comment_body["text"]
        @owner = @comment_body["owner"]

        @owner_id = @owner["id"]
        @owner_username = @owner["username"]

        @comments_json.append({
          'id': @id,
          'text': @text,
          'date': @date,
          'owner_id': @owner_id,
          'owner_username': @owner_username
        })

        @index += 1
      end


      while @media["page_info"]["has_next_page"]

        @variables = '{"shortcode":' + "\"#{@shortcode}\"" + ',"first":1000,"after":' + "\"#{@cursor}\"" + '}'
        @url = "#{@root_url}#{@ext_for_query}?query_hash=#{@query_hash}&variables=#{@variables}"

        html = Nokogiri::HTML(open("#{@url}", "Cookie" => "#{@cookie}"), nil, 'UTF-8')

        @data_json = JSON.parse(html)

        @media = @data_json["data"]["shortcode_media"]["edge_media_to_comment"]

        @cursor = @media["page_info"]["end_cursor"]
        @comments_count = @media["count"]
        @comments = @media["edges"]

        @comments.each do |comment|
          @comment_body = comment["node"]

          @id = @comment_body["id"]
          @date = Time.at(@comment_body["created_at"]).to_datetime
          @text = @comment_body["text"]
          @owner = @comment_body["owner"]

          @owner_id = @owner["id"]
          @owner_username = @owner["username"]

          @comments_json.append({
            'id': @id,
            'text': @text,
            'date': @date,
            'owner_id': @owner_id,
            'owner_username': @owner_username
          })

          @index += 1
        end
      end

      return @comments_json
    end

    def get_user_friends(user_id)
      @users_json = []

      # For FOLLOWING
      @query_hash = "149bef52a3b2af88c0fec37913fe1cbc"
      @cookie = 'csrftoken=rX4tiOGNFc1ZpYswnNZAI4UVOqiG4uRI; shbid=19224; ds_user_id=6133659914; mid=W1cFUgAEAAGWZns_pZuLYPe7jiD5; sessionid=IGSCf9c84d0280cd7fc601736ef4a399c7b0587a225a00d7b3dad90e33bac4695ae1%3As0Bjd7QkLDhxBmgF1L1fblZFg1pI4ADa%3A%7B%22_auth_user_id%22%3A6133659914%2C%22_auth_user_backend%22%3A%22accounts.backends.CaseInsensitiveModelBackend%22%2C%22_auth_user_hash%22%3A%22%22%2C%22_platform%22%3A4%2C%22_token_ver%22%3A2%2C%22_token%22%3A%226133659914%3AcIwPJSmI2D6NJJ7QyIvNHKeBBywTDKyP%3A3e380aeb4436c65903f034746bbc27f95bd19e67cf64f8955a1112c5523aae53%22%2C%22last_refreshed%22%3A1532429650.2432715893%7D; rur=FRC; fbm_124024574287414="base_domain=.instagram.com"; mcd=3; ig_cb=1; shbts=1532450692.7065768; urlgen="{\"time\": 1532449387}:1fi0Ql:w8HnCt8BS-pbuAXBPuyNn_Pkfnk"'

      @variables = '{"id":' + "\"#{user_id}\"" + ',"first":1000' + '}'
      @url = "#{@root_url}#{@ext_for_query}?query_hash=#{@query_hash}&variables=#{@variables}"

      html = Nokogiri::HTML(open(URI.encode("#{@url}"), "Cookie" => "#{@cookie}"), nil, 'UTF-8')

      @data_json = JSON.parse(html)

      @user = @data_json["data"]["user"]
      @media = @user["edge_followed_by"]

      @following_count = @media["count"]
      @cursor = @media["page_info"]["end_cursor"]
      @following = @media["edges"]

      @index = 1
      @following.each do |follow|
        @follow = follow["node"]
        @follow_id = @follow["id"]
        @follow_username = @follow["username"]
        @follow_fullname = @follow["full_name"]

        @users_json.append({
          'id': @follow_id,
          'username': @follow_username,
          'fullame': @follow_fullname
        })

        @index += 1
      end

      while @media["page_info"]["has_next_page"]
        @variables = '{"id":' + "\"#{user_id}\"" + ',"first":1000,"after":' + "\"#{@cursor}\"" + '}'
        @url = "#{@root_url}#{@ext_for_query}?query_hash=#{@query_hash}&variables=#{@variables}"

        html = Nokogiri::HTML(open(URI.encode("#{@url}"), "Cookie" => "#{@cookie}"), nil, 'UTF-8')

        @data_json = JSON.parse(html)

        @user = @data_json["data"]["user"]
        @media = @user["edge_followed_by"]

        @following_count = @media["count"]
        @cursor = @media["page_info"]["end_cursor"]
        @following = @media["edges"]

        @following.each do |follow|
          @follow = follow["node"]
          @follow_id = @follow["id"]
          @follow_username = @follow["username"]
          @follow_fullname = @follow["full_name"]

          @users_json.append({
            'id': @follow_id,
            'username': @follow_username,
            'fullame': @follow_fullname
          })

          @index += 1
        end
      end

      # For FOLLOWERS
      @query_hash = "9335e35a1b280f082a47b98c5aa10fa4"
      @cookie = 'csrftoken=rX4tiOGNFc1ZpYswnNZAI4UVOqiG4uRI; shbid=19224; ds_user_id=6133659914; mid=W1cFUgAEAAGWZns_pZuLYPe7jiD5; sessionid=IGSCf9c84d0280cd7fc601736ef4a399c7b0587a225a00d7b3dad90e33bac4695ae1%3As0Bjd7QkLDhxBmgF1L1fblZFg1pI4ADa%3A%7B%22_auth_user_id%22%3A6133659914%2C%22_auth_user_backend%22%3A%22accounts.backends.CaseInsensitiveModelBackend%22%2C%22_auth_user_hash%22%3A%22%22%2C%22_platform%22%3A4%2C%22_token_ver%22%3A2%2C%22_token%22%3A%226133659914%3AcIwPJSmI2D6NJJ7QyIvNHKeBBywTDKyP%3A3e380aeb4436c65903f034746bbc27f95bd19e67cf64f8955a1112c5523aae53%22%2C%22last_refreshed%22%3A1532429650.2432715893%7D; rur=FRC; fbm_124024574287414="base_domain=.instagram.com"; mcd=3; ig_cb=1; shbts=1532450692.7065768; urlgen="{\"time\": 1532449387}:1fi0Ql:w8HnCt8BS-pbuAXBPuyNn_Pkfnk"'

      @variables = '{"id":' + "\"#{user_id}\"" + ',"first":1000' + '}'
      @url = "#{@root_url}#{@ext_for_query}?query_hash=#{@query_hash}&variables=#{@variables}"

      html = Nokogiri::HTML(open(URI.encode("#{@url}"), "Cookie" => "#{@cookie}"), nil, 'UTF-8')

      @data_json = JSON.parse(html)

      @user = @data_json["data"]["user"]
      @media = @user["edge_follow"]

      @follower_count = @media["count"]
      @cursor = @media["page_info"]["end_cursor"]
      @followers = @media["edges"]

      @index = 1
      @followers.each do |follower|
        @follower = follower["node"]
        @follower_id = @follower["id"]
        @follower_username = @follower["username"]
        @follower_fullname = @follower["full_name"]

        @users_json.append({
          'id': @follower_id,
          'username': @follower_username,
          'fullame': @follower_fullname
        })

        @index += 1
      end

      while @media["page_info"]["has_next_page"]
        @variables = '{"id":' + "\"#{user_id}\"" + ',"first":1000,"after":' + "\"#{@cursor}\"" + '}'
        @url = "#{@root_url}#{@ext_for_query}?query_hash=#{@query_hash}&variables=#{@variables}"

        html = Nokogiri::HTML(open(URI.encode("#{@url}"), "Cookie" => "#{@cookie}"), nil, 'UTF-8')

        @data_json = JSON.parse(html)

        @user = @data_json["data"]["user"]
        @media = @user["edge_follow"]

        @follower_count = @media["count"]
        @cursor = @media["page_info"]["end_cursor"]
        @followers = @media["edges"]

        @followers.each do |follower|
          @follower = follower["node"]
          @follower_id = @follower["id"]
          @follower_username = @follower["username"]
          @follower_fullname = @follower["full_name"]

          @users_json.append({
            'id': @follower_id,
            'username': @follower_username,
            'fullame': @follower_fullname
          })

          @index += 1
        end
      end

      return @users_json
    end

    def get_users_with_tag(tag)
      @users_json = []

      @query_hash = "ded47faa9a1aaded10161a2ff32abb6b"
      @cookie = 'csrftoken=rX4tiOGNFc1ZpYswnNZAI4UVOqiG4uRI; shbid=19224; ds_user_id=6133659914; mid=W1cFUgAEAAGWZns_pZuLYPe7jiD5; sessionid=IGSCf9c84d0280cd7fc601736ef4a399c7b0587a225a00d7b3dad90e33bac4695ae1%3As0Bjd7QkLDhxBmgF1L1fblZFg1pI4ADa%3A%7B%22_auth_user_id%22%3A6133659914%2C%22_auth_user_backend%22%3A%22accounts.backends.CaseInsensitiveModelBackend%22%2C%22_auth_user_hash%22%3A%22%22%2C%22_platform%22%3A4%2C%22_token_ver%22%3A2%2C%22_token%22%3A%226133659914%3AcIwPJSmI2D6NJJ7QyIvNHKeBBywTDKyP%3A3e380aeb4436c65903f034746bbc27f95bd19e67cf64f8955a1112c5523aae53%22%2C%22last_refreshed%22%3A1532429650.2432715893%7D; rur=FRC; fbm_124024574287414="base_domain=.instagram.com"; mcd=3; ig_cb=1; shbts=1532450692.7065768; urlgen="{\"time\": 1532449387}:1fi0Ql:w8HnCt8BS-pbuAXBPuyNn_Pkfnk"'

      puts "#{@root_url}#{@ext_for_tags}#{tag}"
      html = Nokogiri::HTML(open(URI.encode("#{@root_url}#{@ext_for_tags}#{tag}")), nil, 'UTF-8')

      html.css('script').each do |script|
        if script.text.include?("window._sharedData =")
          @data_json = JSON.parse(script.text[21..-2])
        end
      end

      @hashtag = @data_json["entry_data"]["TagPage"][0]["graphql"]["hashtag"]

      @name = @hashtag["name"]
      @media = @hashtag["edge_hashtag_to_media"]
      @has_next_page = @media["page_info"]["has_next_page"]
      @cursor = @media["page_info"]["end_cursor"]
      @posts_count = @media["count"]
      @posts = @media["edges"]

      @index = 1
      @posts.each do |post|
        @post_body = post["node"]
        @id = @post_body["id"]

        if @post_body["edge_media_to_caption"]["edges"] != []
          @text = @post_body["edge_media_to_caption"]["edges"][0]["node"]["text"]
        end

        @date = @post_body["taken_at_timestamp"]
        @shortcode = @post_body["shortcode"]
        @comments_count = @post_body["edge_media_to_comment"]["count"]
        @likes_count = @post_body["edge_liked_by"]["count"]
        @owner_id =  @post_body["owner"]["id"]

        @users_json.append({
          'id': @owner_id,
          'post_shortcode': @shortcode
        })

        @index += 1
      end

      while @has_next_page
        @variables = '{"tag_name":' + "\"#{@name}\"" + ',"first":1000,"after":' + "\"#{@cursor}\"" + '}'
        @url = "#{@root_url}#{@ext_for_query}?query_hash=#{@query_hash}&variables=#{@variables}"

        html = Nokogiri::HTML(open(URI.encode("#{@url}"), "Cookie" => "#{@cookie}"), nil, 'UTF-8')

        if valid_json? html
          @data_json = JSON.parse(html)

          @hashtag = @data_json["data"]["hashtag"]

          @name = @hashtag["name"]
          @media = @hashtag["edge_hashtag_to_media"]
          @has_next_page = @media["page_info"]["has_next_page"]
          @cursor = @media["page_info"]["end_cursor"]
          @posts_count = @media["count"]
          @posts = @media["edges"]

          @posts.each do |post|
            @post_body = post["node"]
            @id = @post_body["id"]

            if @post_body["edge_media_to_caption"]["edges"] != []
              @text = @post_body["edge_media_to_caption"]["edges"][0]["node"]["text"]
            end

            @date = @post_body["taken_at_timestamp"]
            @shortcode = @post_body["shortcode"]
            @comments_count = @post_body["edge_media_to_comment"]["count"]
            @likes_count = @post_body["edge_liked_by"]["count"]
            @owner_id =  @post_body["owner"]["id"]

            @users_json.append({
              'id': @owner_id,
              'post_shortcode': @shortcode
            })

            @index += 1
          end
        else
          @has_next_page_start_id = html.to_s.index('has_next_page":') + 15
          @has_next_page_end_id = html.to_s.index(',', @has_next_page_start_id) - 1

          @end_cursor_start_id = html.to_s.index('end_cursor":"') + 13
          @end_cursor_end_id = html.to_s.index('"', @end_cursor_start_id) - 1

          @has_next_page = html.to_s[@has_next_page_start_id..@has_next_page_end_id]
          @cursor = html.to_s[@end_cursor_start_id..@end_cursor_end_id]
        end
      end

      return @users_json
    end

    def valid_json?(json)
        JSON.parse(json)
        return true
      rescue JSON::ParserError => e
        return false
    end


    def create_user(insta_id, username, fullname, biography, follower_count, following_count)
      @user = User.new(source_id: 1, insta_id: insta_id, username: username, fullname: fullname, biography: biography, follower_count: follower_count, following_count: following_count)
      if @user.save
        puts "User created!"
        puts @user

        return true
      else
        puts "Error occured while creating user!"
        puts @user.errors.full_messages

        return false
      end
    end

    ### DONT FORGET TO ADD VECTOR TO POST AND COMMENT

    def create_post(user_id, user_username, insta_id, shortcode, text, date, vector)
      @post = Post.new(user_id: user_id, user_username: user_username, insta_id: insta_id, shortcode: shortcode, text: text, date: date, vector: vector)
      if @post.save
        puts "Post created!"
        puts @post

        return true
      else
        puts "Error occured while creating post!"
        puts @post.errors.full_messages

        return false
      end
    end

    def create_comment(post_id, owner_id, owner_username, insta_id, text, date, vector)
      @comment = Comment.new(post_id: post_id, owner_id: owner_id, owner_username: owner_username, insta_id: insta_id, text: text, date: date, vector: vector)
      if @comment.save
        puts "Comment created!"
        puts @comment
      else
        puts "Error occured while creating comment!"
        puts @comment.errors.full_messages
      end
    end


    def send_data(data)
      @uri = URI('https://social-ml.herokuapp.com/vectorize')
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @request = Net::HTTP::Post.new(@uri.path, {'Content-Type' => 'application/json'})
      @request.body = data.to_json

      @response = @http.request(@request)
      return @response.body
    end
end
