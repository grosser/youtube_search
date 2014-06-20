require "bundler/setup"
require "bundler/gem_tasks"
require "bump/tasks"

task :default do
  sh "rspec spec/"
end

desc "Update fixtures by downloading them"
task :update_fixtures do
  require 'youtube_search'

  # search
  query = "boat"
  xml = open("http://gdata.youtube.com/feeds/api/videos?#{query}").read
  File.open("spec/fixtures/search_#{query}.xml","w"){|f| f.write xml }

  # playlist
  id = "5F23DAF4BFE3D14C"
  xml = open("http://gdata.youtube.com/feeds/api/playlists/#{id}?v=2").read
  File.open("spec/fixtures/playlist_#{id}.xml","w"){|f| f.write xml }
end
