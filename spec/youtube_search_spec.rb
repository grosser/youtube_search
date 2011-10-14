require 'spec_helper'

describe YoutubeSearch do
  it "has a VERSION" do
    YoutubeSearch::VERSION.should =~ /^[\.\da-z]+$/
  end

  it "can parse xml" do
    # convert to array so we get a nice diff in case of errors
    YoutubeSearch.parse(File.read('spec/fixtures/search_boat.xml')).first.sort.should == [
      ["author",nil],
      ["category", nil],
      ["comments",nil],
      ["content","Top YouTube Videos on tubecrunch.blogspot.com A killer whale swims right up to a boat and shows off his best sounding motor impression."],
      ["group", nil],
      ["id","http://gdata.youtube.com/feeds/api/videos/0b2U5r7Jwkc"],
      ["link",nil],
      ["published","2011-09-29T15:30:43.000Z"],
      ["rating", nil],
      ["statistics",nil],
      ["title","Killer Whale Imitates Boat Motor"],
      ["updated","2011-10-14T07:40:00.000Z"],
      ["video_id", "0b2U5r7Jwkc"],
    ]
  end

  it "can search" do
    YoutubeSearch.search('boat').size.should == 25
  end
end
