$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'youtube_search/version'

Gem::Specification.new "youtube_search", YoutubeSearch::VERSION do |s|
  s.summary = "Search youtube via this simple ruby api"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "http://github.com/grosser/youtube_search"
  s.files = `git ls-files`.split("\n")
end
