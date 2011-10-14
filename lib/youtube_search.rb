require 'rexml/document'
require 'cgi'
require 'open-uri'

module YoutubeSearch
  def self.search(query, options={})
    query = options.merge(:q => query).map{|k,v| "#{CGI.escape k.to_s}=#{CGI.escape v.to_s}" }.join('&')
    xml = open("http://gdata.youtube.com/feeds/api/videos?#{query}").read
    parse(xml)
  end

  def self.parse(xml)
    entries = []
    doc = REXML::Document.new(xml)
    doc.elements.each('feed/entry') do |p|
      entry = Hash[p.children.map do |child|
        [child.name, child.text]
      end]

      entry['video_id'] = entry['id'].split('/').last
      entries << entry
    end
    entries
  end
end
