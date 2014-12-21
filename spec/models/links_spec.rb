require 'spec_helper'

describe 'Links' do

  context 'submitting a valid non-https url' do
    before :each do 
      @orig_url = 'test.com'
      @link = Link.new
      @link.original_url = @orig_url
      @link.setup_short_url(@link)
    end

    it 'creates a new link entry' do 
      expect(Link.last.original_url.include?(@orig_url)).to eq(true)
    end

    it 'properly sanitizes the original url' do 
      expect(Link.last.original_url).to eq("http://#{@orig_url}")
    end
  end

  context 'submitting a url that has already been submitted' do 
    before :each do 
      @orig_url = 'http://test.com'
      @link_first = Link.new
      @link_first.original_url = @orig_url
      @link_first.setup_short_url(@link_first)

      @url_2 = 'www.test.com'
      @link_second = Link.new
      @link_second.original_url = @url_2
      @link_second.setup_short_url(@link_second)
    end

    it 'retrieves the existing link entry' do
      expect(Link.find_by(original_url: @orig_url))
      
      links = []
      Link.all.each do |link|
        links << link if link.original_url.include?('test.com')
      end

      expect(links[0].original_url).to eq('http://test.com')
    end

    it 'does not create a new link entry' do 
      expect(Link.all.length).to eq(1)
      expect(@link_second.id).to eq(nil)
    end
  end

  context 'submitting a valid https url' do
    before :each do 
      @http_url = 'http://test2.com'
      @http_link = Link.new
      @http_link.original_url = @http_url
      @http_link.setup_short_url(@http_link)
      
      @https_url = 'https://test2.com'
      @https_link = Link.new
      @https_link.original_url = @https_url
      @https_link.setup_short_url(@https_link)
    end

    it 'creates a new separate link entry' do
      second_to_last = (Link.find_by(id: Link.last.id-1))

      expect(Link.last.original_url.include?('https://')).to eq(true)
      expect(second_to_last.original_url.include?('https://')).to eq(false)
    end
  end

  context 'submitting an invalid url' do
    before :each do 
      @orig_url = 'gibberish'
      @link = Link.new
      @link.original_url = @orig_url
      @link.setup_short_url(@link)
    end

    it 'does not create a new link entry' do 
      expect(Link.find_by(original_url: @orig_url)).to eq(nil)
    end
  end

end

