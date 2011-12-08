require 'rexml/document'
require 'cgi'
require 'open-uri'

module YoutubeSearch
  def self.search(query, options={})
    options = options_with_per_page_and_page(options)
    query = options.merge(:q => query).map{|k,v| "#{CGI.escape k.to_s}=#{CGI.escape v.to_s}" }.join('&')
    xml = open("http://gdata.youtube.com/feeds/api/videos?#{query}").read
    parse(xml)
  end

  def self.playlist_videos(playlist_id)
    xml = open("https://gdata.youtube.com/feeds/api/playlists/#{playlist_id}?v=2").read
    parse(xml, :type => :playlist)
  end

  def self.parse(xml, options={})
    elements_in(xml, 'feed/entry').map do |element|
      entry = xml_to_hash(element)
      entry['video_id'] = if options[:type] == :playlist
        element.elements['*/yt:videoid'].text
      else
        entry['id'].split('/').last
      end

      entry
    end
  end

  private

  def self.elements_in(xml, selector)
    entries = []
    doc = REXML::Document.new(xml)
    doc.elements.each(selector) do |element|
      entries << element
    end
    entries
  end

  def self.xml_to_hash(element)
    Hash[element.children.map do |child|
      [child.name, child.text]
    end]
  end

  def self.options_with_per_page_and_page(options)
    options = options.dup
    if per_page = options.delete(:per_page)
      options['max-results'] = per_page
    else
      per_page = options['max-results']
    end

    if per_page and page = options.delete(:page)
      options['start-index'] = per_page.to_i * ([page.to_i, 1].max - 1)
    end

    options
  end
end
