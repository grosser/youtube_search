require 'spec_helper'

describe YoutubeSearch do
  it "has a VERSION" do
    YoutubeSearch::VERSION.should =~ /^[\.\da-z]+$/
  end

  describe 'parse' do
    it "can parse xml from a search" do
      # convert to array so we get a nice diff in case of errors
      video = YoutubeSearch.parse(File.read('spec/fixtures/search_boat.xml')).first
      video["content"].should == "Top YouTube Videos on tubecrunch.blogspot.com A killer whale swims right up to a boat and shows off his best sounding motor impression."
      video["duration"].should == "75"
      video["embeddable"].should == false
      video["id"].should == "http://gdata.youtube.com/feeds/api/videos/0b2U5r7Jwkc"
      video["published"].should == "2011-09-29T15:30:43.000Z"
      video["title"].should == "Killer Whale Imitates Boat Motor"
      video["updated"].should == "2011-10-14T07:40:00.000Z"
      video["video_id"].should == "0b2U5r7Jwkc"
      video["raw"].elements.should_not == nil
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

  describe 'playlist_videos' do
    it "can retrieve videos from a playlist" do
      YoutubeSearch.playlist_videos('5F23DAF4BFE3D14C').size.should == 6
    end

    it "can retrieve videos from a playlist with new-style ids" do
      id = 'PL5F23DAF4BFE3D14C'
      YoutubeSearch.playlist_videos(id).size.should == 6
      id.should == 'PL5F23DAF4BFE3D14C'
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
