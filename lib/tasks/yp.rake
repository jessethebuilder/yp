require 'assets/y_p_scrape'

namespace :yp do
  task :scrape => :environment do
    t = Time.now
    puts 'YP Scrape BEGIN -------------------- '

    y = YPScrape.new
    count = y.scrape

    time = Time.now - t

    puts "YP Scrape END in #{time} seconds. #{count} Records were scraped ----------------"
  end

  task :s => :scrape

  task :purge => :environment do
    puts "#{Listing.destroy_all} Listings destroyed!!! ------------------"
  end

  task :p => :purge
end
