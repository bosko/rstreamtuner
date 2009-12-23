require 'rubygems'

__DIR__ = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(__DIR__, 'streams')

require 'stream_api'
require 'station'
require 'shoutcast_stream'

shoutcast = ShoutcastStream.new
#shoutcast.search!('love')
shoutcast.fetch!
File.open('shoutcast.yml', 'w') do |f|
  f.write shoutcast.stations.to_yaml
end

