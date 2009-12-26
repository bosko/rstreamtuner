require 'rubygems'

__DIR__ = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift __DIR__
$LOAD_PATH.unshift File.join(__DIR__, 'streams')
$LOAD_PATH.unshift File.join(__DIR__, 'tk')

require 'stream_api'
require 'station'
require 'shoutcast_stream'
require 'rstreamer_gui'

gui = RStreamerGui.new("Ruby Stream Tuner")
gui.add_stream('Shoutcast')
gui.add_stream('Live365')
gui.start
# shoutcast = ShoutcastStream.new
# shoutcast.search!('love')
# #shoutcast.fetch!
# File.open('shoutcast.yml', 'w') do |f|
#   f.write shoutcast.stations.to_yaml
# end

