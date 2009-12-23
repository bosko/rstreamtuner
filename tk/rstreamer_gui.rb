require 'tk'
require 'tk/stations_frame'

class RStreamerGui
  def initialize(wnd_title)
    @root = TkRoot.new { title wnd_title }
    @stations = StationsFrame.new(@root)
  end

  def start
    @root.mainloop
  end

  def add_stream(item)
    @stations.add_stream(item)
  end
end
