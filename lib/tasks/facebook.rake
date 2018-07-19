#coding: utf-8
namespace :facebook do
    desc "Parsing!"

    @i = 5
    x = 0
    task :user_posts => :environment do
        require "nokogiri"
        require "open-uri"
        require "json"

        html = Nokogiri::HTML(open("https://www.facebook.com/pg/timatimusic/posts?ref=page_internal?offset=0&own=1"))
        
        html.css(".userContent").each do |city|
            puts city.text
            Facebook.create(text: city.text)
            puts " "
            x = x + 1 
        end
        
        loop do
            html = Nokogiri::HTML(open("https://www.facebook.com/pg/timatimusic/posts?ref=page_internal?offset=#{@i}&own=1"))
                
            html.css(".userContent").each do |city|
                puts city.text
                Facebook.create(text: city.text)
                puts " "
                x = x + 1
            end

            if @i > 250
                puts x
                break
            else
                @i += 5
            end
        end
    end

    task :test => :environment do
        require "nokogiri"
        require "open-uri"
        require "json"

        html = Nokogiri::HTML(open("https://www.facebook.com/pages_reaction_units/more?page_id=213919448628740&cursor=%7B%22timeline_cursor%22%3A%22timeline_unit%3A1%3A00000000001530783028%3A04611686018427387904%3A09223372036854775785%3A04611686018427387904%22,%22timeline_section_cursor%22%3A%7B%7D,%22has_next_page%22%3Atrue%7D&surface=www_pages_posts&unit_count=8&dpr=1&__user=100005362802424&__dyn=5V4cjLx2ByK5A9UkKHqAyqomzFEbEyGgS8UR94WqK6EvxGdwIhEpyEyeCHxC7oG5UdUW4UJu9x2axuF8iBAVXxWUPwXGt0Bx12KdwJAAhKe-2h1rDAyF8O49ElwQxSayrBy8G6Ehz8fUlg8VEgABwWGfCCgWrxjyoG3m5pVkdxCi78SaCzUfHGVUhxyh16fmFomhC8xm252odoKUKfy45EGdUcUpx3yUymf-Key8eohx2ezEpVeaDU8Jai5Eynx-6pp8GcByprx65A4Kq0zWDz8uxB1OUtKiaxObwFzGyXw&__a=1&__spin_t=1531837798&__spin_b=trunk&__spin_r=4109503&__rev=4109503&__pc=PHASED%3ADEFAULT&__req=u&__be=1", "cookie" => "datr=L5QqW-iK7m-QghwxxTIg_Z8o; sb=we5NW_VAMxSbCKiBkIcFYrDu; c_user=100005362802424; xs=232%3AtbO8iZsuSaSMKA%3A2%3A1531837796%3A9752%3A8508; pl=n; spin=r.4109503_b.trunk_t.1531837798_s.1_v.2_; fr=0NsP3ubnuJFK0B92a.AWX3p82XFppOPVA-moEaQtwVvxQ.BbIYkw.F2.AAA.0.0.BbT0ke.AWXXyPOi; wd=773x726; act=1531922926831%2F2; presence=EDvF3EtimeF1531923230EuserFA21B05362802424A2EstateFDutF1531923230587CEchFDp_5f1B05362802424F2CC"), nil ,"UTF-8")
        
        puts html
    end

    task :export => :environment do
        Rails.application.eager_load!
    
        file = File.open(File.join(Rails.root, "db", "export", "fb-posts.json"), 'w')
        file.write Facebook.all.to_json
        file.close
    end
end