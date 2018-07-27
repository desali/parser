#coding: utf-8
namespace :tests do
    desc "Testing!"

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
    @user_id_test =         '37029185'
    @post_shortcode_test =  'BVIC06NA3Wv'
    @tag_test =             'tengrinews'

    #VARIABLES FOR FULL PARSING
    @tag = 'абайжолыроманы'

    task :test => :environment do
      @posts = get_user_posts(@username_test)
      @vectors_str = send_data(@posts)
      @vectors = @vectors_str.split(',')

      puts (@vectors)
      puts (@vectors.class)
      puts (@vectors.length)

      for index in (0...@posts.length) do
        if create_post(@user_id_test, @posts[index][:id], @posts[index][:shortcode], @posts[index][:text], @posts[index][:date], @vectors[index])
          puts "Lol"
        end
      end
    end

    task :without_thread => :environment do
      require 'parallel'

      threads = []

      indexes = [1, 1, 1]

      start_time = Time.now

      indexes.each do |index|
        abc(index)
      end

      end_time = Time.now

      puts end_time - start_time
    end

    task :with_thread => :environment do
      require 'parallel'

      threads = []

      start_time = Time.now

      @indexes = [1, 1, 1]

      results = Parallel.map(@indexes) do |index|
        abc(index)
      end

      end_time = Time.now

      puts end_time - start_time
    end

    task :create_source => :environment do
      create_source()
    end

    task :create_user => :environment do
      @user_full_info = get_user_info(@username_test)

      puts @user_full_info

      if create_user(@user_full_info[:id], @user_full_info[:username], @user_full_info[:fullname], @user_full_info[:biography], @user_full_info[:follower_count], @user_full_info[:following_count])

      end
    end

    def abc(index)
      while index < 100000
        puts index
        index += 1
      end
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

    def create_source()
      @source = Source.new(title: 'Intagram', link: "https://www.instagram.com", parse_link: "https://www.instagram.com")
      if @source.save
        puts "Source created!"
        puts @source

        return true
      else
        puts "Error occured while creating source!"
        puts @source.errors.full_messages

        return false
      end
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

    def create_post(user_id, insta_id, shortcode, text, date, vector)
      @post = Post.new(user_id: user_id, insta_id: insta_id, shortcode: shortcode, text: text, date: date, vector: vector)
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


    def send_data(data)
      @uri = URI('http://127.0.0.1:5000/vectorize')
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @request = Net::HTTP::Post.new(@uri.path, {'Content-Type' => 'application/json'})
      @request.body = data.to_json

      @response = @http.request(@request)
      return @response.body
    end
end
