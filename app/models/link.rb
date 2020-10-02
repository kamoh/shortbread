class Link < ActiveRecord::Base

require 'pry'

MOST_VISITED_LIMIT = 100
if ENV["URL_BASE"] == "" || ENV["URL_BASE"] == nil
  URL_BASE = "shrtb.red/"
else
  if !/\/$/.match(ENV["URL_BASE"])
    URL_BASE = ENV["URL_BASE"]  + "/"
  else
    URL_BASE = ENV["URL_BASE"] 
  end 
end 


validates_presence_of :original_url

validates :original_url, format: {
  with: /\S{2}\.\S{1}/,
  message: "Not a valid URL"
}

attr_accessor :link

  def setup_short_url(link)
    # Sets up attr_accessor
    @link = link
    create_short_url
  end

  def create_short_url 
    link = sanitize_link 
    keygen_source = ('a'..'z').to_a.zip('A'..'Z').to_a.zip(1..9).flatten.compact
    retrieved_link = Link.find_by(original_url: original_url)
    # If the link has already been added to the db and shortened, use that record
    if retrieved_link 
      link = retrieved_link
    else
      short_url = keygen_source.shuffle[0,8].join
      link.update(short_url: short_url)
    end
    link
  end

  def sanitize_link
    # test to sanitize to remove slash at the end
    includes_https = false
    # Remove dangling '/'
    link.original_url = link.original_url[0..-2] if link.original_url.last == '/' 
    # Remove 'http://'
    link.original_url = link.original_url[7..-1] if link.original_url[0..6] == 'http://'
    # Remove 'https://'
    if link.original_url[0..7] == 'https://'
      link.original_url = link.original_url[8..-1]
      includes_https = true
    end
    # Remove 'www'
    link.original_url = link.original_url[4..-1] if link.original_url[0..2] == 'www'
    # Ensure the original link has 'http' or 'https' at the start
    includes_https == true ? 
      link.original_url = "https://#{link.original_url}" :
      link.original_url = "http://#{link.original_url}"
    link
  end

end
