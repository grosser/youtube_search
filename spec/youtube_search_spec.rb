require 'spec_helper'

describe YoutubeSearch do
  it "has a VERSION" do
    YoutubeSearch::VERSION.should =~ /^[\.\da-z]+$/
  end
end
