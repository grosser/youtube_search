name = "youtube_search"
require "./lib/#{name}/version"

Gem::Specification.new name, YoutubeSearch::VERSION do |s|
  s.summary = "Search youtube via this simple ruby api"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "https://github.com/grosser/#{name}"
  s.files = `git ls-files lib`.split("\n")
  s.license = "MIT"
end
