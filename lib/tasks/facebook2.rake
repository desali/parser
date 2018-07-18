#coding: utf-8
namespace :facebook do
    desc "Parsing!"
    root_url = "https://www.facebook.com/pg/timatimusic/posts/?ref=page_internal"
    ext_for_posts1 = "?offset="
    ext_for_posts2 = "&own=1"

    task :user_posts => :environment do
      require "nokogiri"
      require "open-uri"
      require 'json'

      html = Nokogiri::HTML(open("#{root_url}"))
      @posts_arr = []

      html.css(".userContentWrapper").each do |post|
        if post.css(".userContent").text[0] != nil
            @posts_arr.push(post.css(".userContent")[0].text)
            puts post.css(".userContent")[0].text
        else
            if post.css(".userContent")[1] != nil
              @posts_arr.push(post.css(".userContent")[1].text)
              puts post.css(".userContent")[1].text
            else
            end
        end
    
    end

    @cur_index = 10

    loop do
    puts "#{root_url}#{ext_for_posts1}#{@cur_index}#{ext_for_posts2}"
    html = Nokogiri::HTML(open("#{root_url}#{ext_for_posts1}#{@cur_index}#{ext_for_posts2}"))

    puts html.css(".userContentWrapper").count
    html.css(".userContent").each do |post|
        if post.css(".userContent")[0] != nil
        @posts_arr.push(post.css(".userContent")[0].text)
        puts post.css(".userContent")[0].text
        else
            if post.css(".userContent")[1] != nil
            @posts_arr.push(post.css(".userContent")[1].text)
            puts post.css(".userContent")[1].text
            else
            end
        end
        end
    end

        if @cur_index + 10 > 200
        break
        else
        @cur_index += 10
        end
        
        puts @posts_arr.count
    end
end



