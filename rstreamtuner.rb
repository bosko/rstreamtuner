require 'rubygems'

__DIR__ = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift __DIR__
$LOAD_PATH.unshift File.join(__DIR__, 'streams')
$LOAD_PATH.unshift File.join(__DIR__, 'tk')

require 'stream_api'
require 'station'
require 'rstreamer_gui'

Dir.glob('./streams/*.rb') do |s|
  require File.expand_path(s)
end

gui = RStreamerGui.new("Ruby Stream Tuner")
gui.start
# shoutcast = ShoutcastStream.new
# shoutcast.search!('love')
# #shoutcast.fetch!
# File.open('shoutcast.yml', 'w') do |f|
#   f.write shoutcast.stations.to_yaml
# end

