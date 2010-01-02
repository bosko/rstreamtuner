require 'stations_list'

include Wx

class MainFrame < Wx::Frame

  CLOSE_APP = 101

  STREAMS_LIST = 1000
  STATIONS_LIST = 1001

  def initialize
    super(nil, -1, "Ruby Stream Tuner",
          DEFAULT_POSITION, Size.new(700,500), DEFAULT_FRAME_STYLE)
    create_status_bar
    create_menu
    splitter = Wx::SplitterWindow.new(self,-1)

    create_streams_list(splitter)
    create_stations_list(splitter)
    
    # p2 = Wx::Window.new(splitter, -1)
    # p2.set_background_colour(Wx::BLUE)
    # Wx::StaticText.new(p2, -1, "Panel Two", Wx::Point.new(5,5)).set_background_colour(Wx::BLUE)

    splitter.set_minimum_pane_size(20)
    splitter.split_vertically(@streams,@stations,100)
  end

  def create_menu
    menu_bar = Wx::MenuBar.new

    file_menu = Wx::Menu.new
    file_menu.append(CLOSE_APP,"&Close", "Close application")
    menu_bar.append(file_menu, '&File')
    set_menu_bar(menu_bar)
    evt_menu(CLOSE_APP) {|event| close_window(event)}
  end

  def create_streams_list(splitter)
    @streams = Wx::ListBox.new(splitter,STREAMS_LIST)
    StreamAPI.streams.each do |name,stream|
      @streams.append(name, stream.new)
    end
    @streams.evt_listbox(@streams.id) { |event| on_stream_selected(event) }
  end

  def create_stations_list(splitter)
    @stations = StationsList.new(splitter, STATIONS_LIST)
    @stations.evt_list_item_activated(@stations.id) { |event| on_station_activated(event) }
  end
  
  def close_window(event)
    event.skip
    close(true)
  end

  def on_stream_selected(event)
    return unless event.get_client_data.is_a? StreamAPI
    event.get_client_data.fetch!
    if @stations
      @stations.item_count = event.get_client_data.stations.length
      @stations.stations = event.get_client_data.stations
    end
  end

  def on_station_activated(event)
    cur_item = @stations.stations[event.index]
    `"audacious2 #{cur_item.tune_in}"`
  end
end
