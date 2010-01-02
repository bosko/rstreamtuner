require 'tk'
require "tkextlib/tile"
require 'tk/stations_frame'

class RStreamerGui
  def initialize(wnd_title)
    @root = TkRoot.new { title wnd_title }

    @menu = TkMenu.new()
    
    @file_menu = TkMenu.new(@menu)
    @file_menu.add(:command, :label=>'Quit', :command=>proc{@root.destroy})
    @menu.add(:cascade, :menu=>@file_menu, :label=>'File')

    @root.menu(@menu)

    @stations = StationsFrame.new(@root)
    load_streams
  end

  def start
    @root.mainloop
  end

  def load_streams
    StreamAPI.streams.each do |name,klass|
      @stations.add_stream name
    end
  end
end
