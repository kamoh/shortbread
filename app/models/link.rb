class Link < ActiveRecord::Base

URL_BASE = "shrtb.red/"
MOST_VISITED_LIMIT = 100

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
    # Ensure the original link has http or https at the start
    return link if link.original_url.include?('http://') || link.original_url.include?('https://')
    link.original_url = "http://#{link.original_url}"
    link
  end

end
