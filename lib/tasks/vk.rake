#coding: utf-8
namespace :vk do
    desc "Parsing!"
    root_url = "https://m.vk.com/molodost_bz"
    ext_for_posts1 = "?offset="
    ext_for_posts2 = "&own=1"

    task :export => :environment do
      Rails.application.eager_load!

      file = File.open(File.join(Rails.root, "db", "export", "posts.json"), 'w')
      file.write Post.all.to_json
      file.close
    end


    task :group_posts => :environment do
      require "nokogiri"
      require "open-uri"
      require 'json'

      html = Nokogiri::HTML(open("#{root_url}"))
      @posts_arr = []

      html.css(".wall_item").each do |post|
        if post.css(".pi_text")[0] != nil
          @posts_arr.push(post.css(".pi_text")[0].text)
          puts post.css(".pi_text")[0].text
          Post.create(text: post.css(".pi_text")[0].text)
        else
          if post.css(".pi_text")[1] != nil
            @posts_arr.push(post.css(".pi_text")[1].text)
            puts post.css(".pi_text")[1].text
            Post.create(text: post.css(".pi_text")[1].text)
          else

          end
        end
      end


      if html.css(".slim_header_label").text == ""
        @posts_count = html.css(".slim_header")[3].text.to_i
      else
        @posts_count = html.css(".slim_header_label").text.to_i
      end

      puts @posts_count

      @cur_index = 5

      loop do
        puts "#{root_url}#{ext_for_posts1}#{@cur_index}#{ext_for_posts2}"

        html = Nokogiri::HTML(open("#{root_url}#{ext_for_posts1}#{@cur_index}#{ext_for_posts2}"))

        puts html.css(".wall_item").count

        html.css(".wall_item").each do |post|
          if post.css(".pi_text")[0] != nil
            @posts_arr.push(post.css(".pi_text")[0].text)
            puts post.css(".pi_text")[0].text
            Post.create(text: post.css(".pi_text")[0].text)
          else
            if post.css(".pi_text")[1] != nil
              @posts_arr.push(post.css(".pi_text")[1].text)
              puts post.css(".pi_text")[1].text
              Post.create(text: post.css(".pi_text")[1].text)
            else

            end
          end
        end

        if @cur_index + 10 > 1000
          break
        else
          @cur_index += 10
        end
      end

      puts @posts_arr.count
    end
end
