class Link < ActiveRecord::Base

require 'pry'
require 'base64'

  def create_short_url(link)
    short_url = Base64.encode64(link.original_url).gsub(" ","").gsub("=","").strip
    # Shorten the encoded link further - right now Base64 is too long
    retrieved_link = Link.find_by(short_url: short_url)
    # If the link has already been shortened, use that entry
    if retrieved_link 
      link = retrieved_link
    else
      link.update(short_url: short_url)
    end
    # Increment the 'times visited' column for Top 100 view
    link.times_visited += 1
    link.save!
    link
  end

end
