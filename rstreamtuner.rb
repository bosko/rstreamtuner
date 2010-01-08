__DIR__ = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift __DIR__
$LOAD_PATH.unshift File.join(__DIR__, 'streams')
$LOAD_PATH.unshift File.join(__DIR__, 'wx')

require 'rubygems'
require 'rst_config'
require 'stream_api'
require 'wx'
require 'main_frame'

Dir.glob("#{__DIR__}/streams/*.rb") do |s|
  require File.expand_path(s)
end

class RStreamTunerApp < Wx::App
  def on_init
    f = MainFrame.new
    f.show(true)
  end
end

app = RStreamTunerApp.new
app.main_loop
