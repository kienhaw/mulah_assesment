class MulahController < ApplicationController
  require "HTTParty"
  require "nokogiri"

  # retrieve from pre-generated JSON file (collected from calling scapper service)
  def index
    json_file = File.read("#{Rails.root}/public/scraped-data.json")
    render json: { data: JSON.parse(json_file)["data"] }
  end

  # real time retrieval
  # def index
  #   url = "https://sea.mashable.com/"
  #   response = HTTParty.get(url)
  #   html = response.body

  #   doc = Nokogiri::HTML(html)

  #   links = doc.css(".blogroll a")
  #   @articles = []
  #   links.each_with_index do |link, index|
  #     href_tag = link["href"]
  #     title = link.css(".caption").text
  #     datetime = link.css(".datepublished").text
  #     @articles << {
  #       href: href_tag,
  #       title: title,
  #       datetime: datetime,
  #       datetime_minor: DateTime.parse(datetime).to_date
  #     }
  #   end

  #   page = 2 # the site starts with page 2 when we click "show more"
  #   to_break = false
  #   loop do
  #     response = HTTParty.get("#{url}?page=#{page}&ist=broll")
  #     html = response.body
  #     doc = Nokogiri::HTML(html)

  #     links = doc.css(".blogroll a")
  #     links.each_with_index do |link, index|
  #       href_tag = link["href"]
  #       title = link.css(".caption").text
  #       datetime = link.css(".datepublished").text
  #       minor_date = DateTime.parse(datetime).to_date
  #       # push each article into an array
  #       @articles << {
  #         href: href_tag,
  #         title: title,
  #         datetime: datetime,
  #         datetime_minor: minor_date
  #       }
  #       # boolean to check if the article was past 1st of Jan 2022
  #       to_break = minor_date < DateTime.parse("01-01-2022").to_date
  #       # stop calling API to get articles
  #       break if to_break
  #     end
  #     # stop the entire loop
  #     break if to_break
  #     sleep 1
  #     page += 1
  #   end

  #   render json: { data: @articles }
  # end
end
