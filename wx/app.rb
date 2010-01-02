require 'rubygems'
require 'wx'
require 'main_frame'

class RStreamTunerApp < Wx::App
  def on_init
    f = MainFrame.new
    f.show(true)
  end
end
