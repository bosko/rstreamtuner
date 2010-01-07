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

    create_streams_tree(splitter)
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

  def create_streams_tree(splitter)
    @streams = Wx::TreeCtrl.new(splitter, STREAMS_LIST)
    root = @streams.add_root("Streams")
    StreamAPI.streams.each do |name,stream|
      stream_node = @streams.append_item(root, name)
      @streams.set_item_data(stream_node, stream.new)
      @streams.append_item(stream_node, "Search")
    end
    @streams.expand(root)
    @streams.evt_tree_sel_changed(@streams.id) { |event| on_node_selected(event) }
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

  def search(stream, search_node)
    dlg = Wx::TextEntryDialog.new(self, "Enter search term",
                                  "Search #{stream.name} stream")
    dlg.show_modal
    stream.search! dlg.get_value if dlg.get_value
    # Fill search nodes here
  end
      
  def on_node_selected(event)
    @cur_stream = @streams.get_item_data(event.get_item())
    if @cur_stream and @cur_stream.is_a? StreamAPI
      Wx::begin_busy_cursor
      fetched = @cur_stream.fetch!
      if @stations
        @stations.columns = @cur_stream.columns
        @stations.item_count = fetched.length
        get_status_bar().push_status_text "Number of stations: #{fetched.length}"
        @stations.stations = fetched
      end
      Wx::end_busy_cursor
    else
      stream_node = @streams.get_item_parent(event.get_item())
      stream = @streams.get_item_data(stream_node)
      if stream and stream.is_a? StreamAPI
        search(stream, event.get_item())
      end
    end
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
