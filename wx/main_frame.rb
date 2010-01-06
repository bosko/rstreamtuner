require 'rbconfig'
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
    @stations.evt_list_col_end_drag(@stations.id) { |event| on_column_width_changed(event) } 
  end
  
  def close_window(event)
    event.skip
    close(true)
  end

  def on_stream_selected(event)
    return unless event.get_client_data.is_a? StreamAPI
    Wx::begin_busy_cursor
    @cur_stream = event.get_client_data
    @cur_stream.fetch!
    if @stations
      @stations.columns = @cur_stream.columns
      @stations.item_count = @cur_stream.stations.length
      get_status_bar().push_status_text "Number of stations: #{@cur_stream.stations.length}"
      @stations.stations = @cur_stream.stations
    end
    Wx::end_busy_cursor
  end

  def on_station_activated(event)
    pls_file = @cur_stream.pls_file event.index
    return unless File.exist? pls_file
    Wx::begin_busy_cursor
    if Config::CONFIG['host_os'] =~ /mswin|mingw/
      # Windows player
      IO.popen "c:/Program Files (x86)/AIMP2/AIMP2.exe #{pls_file}"
    else
      IO.popen "audacious2 #{pls_file}"
    end
    
    Wx::end_busy_cursor
  end

  def on_column_width_changed(event)
    @cur_stream.column_width(event.get_column, @stations.column_width(event.get_column))
  end
end
