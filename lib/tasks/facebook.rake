#coding: utf-8
namespace :facebook1 do
    desc "Parsing!"

    i = 5
    x = 0
    task :user_posts => :environment do
        require "nokogiri"
        require "open-uri"
        require "json"

        html = Nokogiri::HTML(open("https://www.facebook.com/pg/timatimusic/posts/?ref=page_internal?offset=0&own=1"))
            html.css(".userContent").each do |city|
                puts city.text
                puts " "
                x = x + 1 
                end
        loop do
            html = Nokogiri::HTML(open("https://www.facebook.com/pg/timatimusic/posts/?ref=page_internal?offset=#{i}&own=1"))
            i = i + 5
                html.css(".userContent").each do |city|
                puts city.text
                puts " "
                x = x + 1
                end

                if i > 250
                    puts x
                    break
                end 
            end
        end
    end