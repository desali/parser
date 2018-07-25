# coding: utf-8

namespace :insta do
    desc "Parsing Instagram!"

    require "nokogiri"
    require "open-uri"
    require 'json'

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
    @tag = ''

    task :parse_full_test => :environment do
      @users_with_shortcode = get_users_with_tag(@tag)

      @users_with_shortcode.each do |user|
        @user = get_user(user["post_shortcode"])
        @user_username = @user["username"]
        @user_id = @user["id"]
        @user_full_info = get_user_info(@user_username)
        # Create User with full info

        @posts = get_user_posts(@user_username)
        # Send all posts to ml server
        # Then with response of vectors create posts

        @posts.each do |post|
          @comments = get_post_comments(@user_username, post["shortcode"])
          # Send all comments to ml server
          # Then with response of vectors create comments
        end

        @friends = get_user_friends(@user_id)

        @friends.each do |friend|
          @friend_username = friend["username"]
          @friend_id = friend["id"]
          @friend_full_info = get_user_info(@friend_username)
          # Create User with full info

          @posts = get_user_posts(@friend_username)
          # Send all posts to ml server
          # Then with response of vectors create posts

          @posts.each do |post|
            @comments = get_post_comments(@friend_username, post["shortcode"])
            # Send all comments to ml server
            # Then with response of vectors create comments
          end
        end
      end
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


    def get_user(post_shortcode)
      @url = "#{@root_url}#{@ext_for_post0}#{post_shortcode}"

      puts @url
      html = Nokogiri::HTML(open("#{@url}"), nil, 'UTF-8')

      html.css('script').each do |script|
        if script.text.include?("window._sharedData =")
          @data_json = JSON.parse(script.text[21..-2])
        end
      end

      @post = @data_json["entry_data"]["PostPage"][0]["graphql"]["shortcode_media"]
      @owner = @post["owner"]

      return @owner
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
        @date = @post_body["taken_at_timestamp"]
        @comments_count = @post_body["edge_media_to_comment"]["count"]
        @likes_count = @post_body["edge_liked_by"]["count"]

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


      while @media["page_info"]["has_next_page"]
        puts 'Request'

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
          @date = @post_body["taken_at_timestamp"]
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
      @text = @post["edge_media_to_caption"]["edges"][0]["node"]["text"]

      @media = @post["edge_media_to_comment"]
      @cursor = @media["page_info"]["end_cursor"]

      @comments_count = @media["count"]
      @comments = @media["edges"]

      @index = 1
      @comments.each do |comment|
        @comment_body = comment["node"]

        @id = @comment_body["id"]
        @date = @comment_body["created_at"]
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
        puts "request"

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
          @date = @comment_body["created_at"]
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

      puts "Tag posts have: #{@posts.count}"

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
        puts @url

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

          puts "Tag posts have: #{@posts.count}"

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
              'id': @owner_id
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
    end

    def valid_json?(json)
        JSON.parse(json)
        return true
      rescue JSON::ParserError => e
        return false
    end

    # Add insta_id to all!!!
    # Add insta_id to all!!!
    # Add insta_id to all!!!

    def create_user(source_id, username, fullname, biography, created_at, follower_count, following_count)
      User.create()
    end

    def create_post(user_id, shortcode, text, created_at, location, location_id, vector)
      Post.create()
    end

    def create_comment(post_id, owner_id, owner_username, text, created_at, vector)
      Comment.create()
    end
end
