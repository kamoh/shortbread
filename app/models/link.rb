class Link < ActiveRecord::Base

require 'pry'
require 'base64'

URL_BASE = "shrtb.red/"

validates_presence_of :original_url

validates :original_url, format: {
  with: /\S{2}\.\S{1}/,
  message: "Not a valid URL"
}

  def create_base_url(link)
    short_url = Base64.encode64(link.original_url).gsub(" ","").gsub("=","").strip
    short_url = shorten_base_url(short_url, link)
    retrieved_link = Link.find_by(short_url: short_url)
    # If the link has already been shortened, use that entry
    if retrieved_link 
      link = retrieved_link
    else
      link.update(short_url: short_url)
    end
    link
  end

  def shorten_base_url(short_url, link)
    if short_url.length < 9
      short_url = short_url += short_url 
    end
    shortened_base_url = ""
    marker = link.original_url.length.to_s[-1]
    lower_bound = -marker.to_i
    upper_bound = -marker.to_i-4
    until shortened_base_url == nil
      lower_bound -= 1
      shortened_base_url = Link.find_by(short_url: short_url[lower_bound..upper_bound])
    end
    shortened_base_url = short_url[lower_bound..upper_bound]
  end

end
