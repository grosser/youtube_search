# encoding: utf-8
require 'spec_helper'

describe YoutubeSearch do
  it "has a VERSION" do
    YoutubeSearch::VERSION.should =~ /^[\.\da-z]+$/
  end

  describe 'parse' do
    let(:canned_xml){ File.read('spec/fixtures/search_boat.xml') }

    it "can parse xml from a search" do
      # convert to array so we get a nice diff in case of errors
      video = YoutubeSearch.parse(canned_xml).first
      video["content"].should == "Top YouTube Videos on tubecrunch.blogspot.com A killer whale swims right up to a boat and shows off his best sounding motor impression."
      video["duration"].should == "75"
      video["id"].should == "http://gdata.youtube.com/feeds/api/videos/0b2U5r7Jwkc"
      video["published"].should == "2011-09-29T15:30:43.000Z"
      video["title"].should == "Killer Whale Imitates Boat Motor"
      video["updated"].should == "2011-10-14T07:40:00.000Z"
      video["video_id"].should == "0b2U5r7Jwkc"
      video["raw"].elements.should_not == nil
    end

    context "embeddable" do
      it "is embeddable if neither private nor noembed are set" do
        video = YoutubeSearch.parse(canned_xml).last
        video["embeddable"].should == true
      end

      it "is not embeddable if noembed is set" do
        xml = canned_xml.sub('</entry>','<yt:noembed/></entry>')
        video = YoutubeSearch.parse(xml).first
        video["embeddable"].should == false
      end

      it "is not embeddable if private is set" do
        xml = canned_xml.sub('</entry>','<yt:private/></entry>')
        video = YoutubeSearch.parse(xml).first
        video["embeddable"].should == false
      end
    end

    it "can parse xml from a playlist" do
      video = YoutubeSearch.parse(File.read('spec/fixtures/playlist_5F23DAF4BFE3D14C.xml'), :type => :playlist).first
      video["duration"].should == "192"
      video["id"].should == "tag:youtube.com,2008:playlist:5F23DAF4BFE3D14C:kRk0fUfl9UJvHjGFHgPSakUFmztBgGKG"
      video["position"].should == "1"
      video["recorded"].should == "2010-01-08"
      video["title"].should == "Osteopatia y terapias manuales"
      video["updated"].should == "2011-12-07T01:46:21.650Z"
      video["video_id"].should == "5wU-yHnq7Hs"
      video["raw"].elements.should_not == nil
    end

    it "can parse xml from playlists search" do
      playlists = YoutubeSearch.parse(File.read('spec/fixtures/playlist_search_google_developers.xml'))
      playlists.size.should == 10
      playlists[0]["id"].should ==  "tag:youtube.com,2008:playlist:snippet:PLB09682344C2F233B"
      playlists[0]["published"].should == "2010-05-21T05:05:09.000Z"
      playlists[0]["updated"].should == "2012-08-23T12:33:57.000Z"
      playlists[0]["title"].should == "Google I/O 2010: Google TV Keynote, Day 2"
      playlists[0]["playlistId"].should == "PLB09682344C2F233B"
    end
  end

  describe 'search' do
    it "can search" do
      YoutubeSearch.search('boat').size.should == 25
    end

    it "can search for complex examples" do
      YoutubeSearch.search('Left 4 Dead 2').size.should == 25
    end

    it "can search with options" do
      YoutubeSearch.search('Left 4 Dead 2', 'max-results' => 2).size.should == 2
    end

    it "can search with :per_page" do
      YoutubeSearch.search('Left 4 Dead 2', :per_page => 2).size.should == 2
    end
  end

  describe 'search_playlists' do
    it "can search playlists" do
      YoutubeSearch.search_playlists('GoogleDevelopers').size.should == 25
    end

    it "can search with options" do
      YoutubeSearch.search_playlists('GoogleDevelopers', 'max-results' => 2).size.should == 2
    end

    it "can search with :per_page" do
      YoutubeSearch.search('GoogleDevelopers', :per_page => 2).size.should == 2
    end
  end

  describe 'playlist_videos' do
    it "can retrieve videos from a playlist" do
      YoutubeSearch.playlist_videos('5F23DAF4BFE3D14C').size.should == 6
    end

    it "can retrieve videos from a playlist with new-style ids" do
      id = 'PL5F23DAF4BFE3D14C'
      YoutubeSearch.playlist_videos(id).size.should == 6
      id.should == 'PL5F23DAF4BFE3D14C'
    end

    it "can retrieve videos from a playlist in json format" do
      videos = JSON.parse(
        YoutubeSearch.playlist_videos('5F23DAF4BFE3D14C', :format => :json)
      )['feed']['entry']
      videos.size.should == 6
    end
  end

  describe 'user_channel_videos' do
    it "can retrieve videos from a channel" do
      YoutubeSearch.user_channel_videos('UCShuVWEZ2KhSb2kAYd7-StQ').size.should == 25
    end

    it "can retrieve videos from a channel in json format" do
      videos = JSON.parse(
        YoutubeSearch.user_channel_videos('UCShuVWEZ2KhSb2kAYd7-StQ', :format => :json)
      )['feed']['entry']
      videos.size.should == 25
    end
  end

  describe 'options_with_per_page_and_page' do
    it "converts :page and :per_page" do
      YoutubeSearch.send(:options_with_per_page_and_page, {:page => 2, :per_page => 4}).should ==
        {"max-results"=>4, "start-index"=>4}
    end

    it "assumes page 1 for nil/0 page" do
      YoutubeSearch.send(:options_with_per_page_and_page, {:page => '', :per_page => 4}).should ==
        {"max-results"=>4, "start-index"=>0}
    end

    it "uses :page + max-results" do
      YoutubeSearch.send(:options_with_per_page_and_page, {:page => 2, 'max-results' => 4}).should ==
        {"max-results"=>4, "start-index"=>4}
    end

    it "uses start-index + :per_page" do
      YoutubeSearch.send(:options_with_per_page_and_page, {'start-index' => 2, :per_page => 4}).should ==
        {"max-results"=>4, "start-index"=>2}
    end
  end
end
