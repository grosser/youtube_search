require 'rexml/document'
require 'cgi'
require 'open-uri'

module YoutubeSearch
  class << self
    def search_page(page, query, options={})
      options = options_with_per_page_and_page(options)
      query = options.merge(:q => query).map{|k,v| "#{CGI.escape k.to_s}=#{CGI.escape v.to_s}" }.join('&')
      xml = open("#{page}?#{query}").read
      parse(xml)
    end

    def search(query, options={})
      search_page("http://gdata.youtube.com/feeds/api/videos", query, options)
    end

    def search_playlists(query, options={})
      search_page("https://gdata.youtube.com/feeds/api/playlists/snippets", query, options.merge(:v => 2))
    end

    def playlist_videos(playlist_id, format='xml')
      playlist_id = playlist_id.sub(/^PL/, "")
      res = open("http://gdata.youtube.com/feeds/api/playlists/#{playlist_id}?v=2#{'&alt=json' if format == 'json'}").read
      if format == 'xml'
        parse(res, :type => :playlist)
      else
        res
      end
    end

    def parse(xml, options={})
      elements_in(xml, 'feed/entry').map do |element|
        entry = xml_to_hash(element)
        entry['video_id'] = if options[:type] == :playlist
          element.elements['*/yt:videoid'].text
        else
          entry['id'].split('/').last
        end

        duration = element.elements['*/yt:duration']
        entry['duration'] = duration.attributes['seconds'] if duration

        no_embed = element.elements['yt:noembed'] || element.elements['yt:private']
        entry['embeddable'] = !(no_embed)

        entry['raw'] = element

        entry
      end
    end

    private

    def elements_in(xml, selector)
      entries = []
      doc = REXML::Document.new(xml)
      doc.elements.each(selector) do |element|
        entries << element
      end
      entries
    end

    def xml_to_hash(element)
      Hash[element.children.map do |child|
        [child.name, child.text]
      end]
    end

    def options_with_per_page_and_page(options)
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
end
