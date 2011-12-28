require "bundler"
Bundler::GemHelper.install_tasks

task :default do
  sh "rspec spec/"
end

rule /^version:bump:.*/ do |t|
  sh "git status | grep 'nothing to commit'" # ensure we are not dirty
  index = ['major', 'minor','patch'].index(t.name.split(':').last)
  file = 'lib/youtube_search/version.rb'

  version_file = File.read(file)
  old_version, *version_parts = version_file.match(/(\d+)\.(\d+)\.(\d+)/).to_a
  version_parts[index] = version_parts[index].to_i + 1
  new_version = version_parts * '.'
  File.open(file,'w'){|f| f.write(version_file.sub(old_version, new_version)) }

  sh "bundle && git add #{file} Gemfile.lock && git commit -m 'bump version to #{new_version}'"
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