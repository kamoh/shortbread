class Link < ActiveRecord::Base

require 'pry'
require 'base64'

URL_BASE = "shrtb.red/"

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
    lower_bound = -4
    upper_bound = -1
    until shortened_base_url == nil
      shortened_base_url = Link.find_by(short_url: short_url[lower_bound..upper_bound])
      lower_bound -= 1
    end
    shortened_base_url = short_url[lower_bound..upper_bound]
  end

end
