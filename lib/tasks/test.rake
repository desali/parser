#coding: utf-8
namespace :test do
    desc "Testing!"

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

    def abc(index)
      while index < 100000
        puts index
        index += 1
      end
    end
end
