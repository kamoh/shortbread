class Link < ActiveRecord::Base

URL_BASE = "shrtb.red/"

validates_presence_of :original_url

validates :original_url, format: {
  with: /\S{2}\.\S{1}/,
  message: "Not a valid URL"
}

  def create_short_url(link)
    keygen_source = ('a'..'z').to_a.zip('A'..'Z').to_a.zip(1..9).flatten.compact
    retrieved_link = Link.find_by(original_url: original_url)
    # If the link has already been added to the db and shortened, use that link
    if retrieved_link 
      link = retrieved_link
    else
      short_url = keygen_source.shuffle[0,8].join
      link.update(short_url: short_url)
    end
    link
  end

end
