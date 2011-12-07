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

  def self.playlist(playlist_id)
    xml = open("https://gdata.youtube.com/feeds/api/playlists/#{playlist_id}?v=2").read
    parse(xml, true)
  end

  def self.parse(xml, playlist = false)
    entries = []
    doc = REXML::Document.new(xml)
    doc.elements.each('feed/entry') do |p|

      entry = Hash[p.children.map do |child|
        [child.name, child.text]
      end]

      if playlist
        videoid = p.elements['*/yt:videoid'].text
      else
        videoid = entry['id'].split('/').last
      end

      entry['video_id'] = videoid
      entries << entry
    end
    entries
  end

  private

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
