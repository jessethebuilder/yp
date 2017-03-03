# require 'farm_scrape'

class YPScrape
  YP_URL_BASE = "https://www.yellowpages.com"
  # attr_accessor :scraper

  def initialize
    @mech = Mechanize.new
    @total_pages_scraped = 0
  end

  def scrape
    num = 0
    begin
      num += 1
    end while scrape_index(num) > 0

    return @total_pages_scraped
  end

  def scrape_index(page_number)
    # returns number of found (though not necessarily scraped)
    url = yp_index_url(page_number)
    page = @mech.get(url)
    links = page.parser.css(".organic .business-name")

    @total_pages_scraped += scrape_pages(links)

    return links.count
  end

  def scrape_pages(links)
    # returns total number of pages actually scraped
    count = 0
    links.each do |l|
      url = "#{YP_URL_BASE}#{l.attributes['href']}"
      unless dont_scrape?(url)
        # if scrape is successful, add 1 to the count
        count += 1 if scrape_show(url)
      end
    end

    return count
  end

  def scrape_show(url)
    puts "Scraping #{url}"

    page = @mech.get(url)
    l = Listing.new(url: url)

    l.street = page.parser.css('span[itemprop="streetAddress"]').text.gsub(/,? $/, '')
    l.city = page.parser.css('span[itemprop="addressLocality"]').text.gsub(/,? $/, '')
    l.state = page.parser.css('span[itemprop="addressRegion"]').text.gsub(/,? $/, '')
    l.zip = page.parser.css('span[itemprop="postalCode"]').text

    country = page.parser.css('meta[itemprop="addressCountry"]')
    l.country = country.attribute('content') unless country.empty?

    website = page.parser.css('.website-link')
    l.website = website.attribute('href') unless website.empty?

    email = page.parser.css('.email-business')
    l.email = email.attribute('href').to_s.gsub(/^mailto:/, '') unless email.empty?

    l.phone = page.parser.css('p[itemprop="telephone"]').children.text.strip

    l.description = page.parser.css('dl dd.general-info').text

    l.brands = page.parser.css('dl dd.brands').text.split(/, ?/)

    cats = []
    page.parser.css('dl dd.categories').children.each do |c|
      cats << c.text.gsub(/, ?/, '')
    end

    l.categories = cats

    l.save
  end


  private

  def dont_scrape?(url)
    # check to see if URL has been saved.
    Listing.where(url: url).count > 0
  end

  def yp_index_url(page_number)
    "#{YP_URL_BASE}/search?search_terms=#{terms}&geo_location_terms=#{locations}&page=#{page_number}"
  end

  def terms
    @terms ||= ENV['YP_SEARCH_TERMS'].downcase.gsub(' ', '+')
  end

  def locations
    @locations ||= ENV['YP_LOCATIONS'].downcase.gsub(' ', '+').gsub(',', '%2C')
  end
end
