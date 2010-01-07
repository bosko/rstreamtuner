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
    StreamAPI.streams.each do |name,stream_klass|
      stream_node = @streams.append_item(root, name)
      stream = stream_klass.new
      # Store stream in the node's data
      @streams.set_item_data(stream_node, stream)
      search_node = @streams.append_item(stream_node, "Search")
      stream.search_terms.each do |search_term|
        term_node = @streams.append_item(search_node, search_term)
        # Store search term in the node's data
        @streams.set_item_data(term_node, search_term)
      end
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

  def search(stream, search_node, search_term)
    stations = Array.new
    if stream.nil? or !stream.is_a?(StreamAPI) or search_term.empty?
      return stations
    end

    @streams.get_children(search_node).each do |criteria_node|
      if @streams.get_item_data(criteria_node) == search_term
        # If we already have node with this search term select it and
        # return
        @streams.select_item(criteria_node, true)
        return stations
      end
    end

    criteria_node = @streams.append_item(search_node, search_term)
    @streams.set_item_data(criteria_node, search_term)
    
    @streams.expand(search_node)
    @streams.select_item(criteria_node, true)
    stations = stream.search! search_term
    stream.save_cache
    stations
  end
      
  def on_node_selected(event)
    item = event.get_item()
    if item == @streams.get_root_item
      set_stations(nil)
      return
    end

    data = @streams.get_item_data(item)
    if data and data.is_a? StreamAPI
      Wx::begin_busy_cursor
      @cur_stream = data
      fetched = @cur_stream.fetch!
      set_stations(@cur_stream.columns, fetched)
      get_status_bar().push_status_text "Number of stations: #{fetched.length}"
      Wx::end_busy_cursor
    elsif !data.nil?
      Wx::begin_busy_cursor
      term_node = event.get_item()
      search_node = @streams.get_item_parent(term_node)
      stream_node = @streams.get_item_parent(search_node)

      @cur_stream = @streams.get_item_data(stream_node)
      set_stations(@cur_stream.columns, @cur_stream.search!(data))
      Wx::end_busy_cursor
    else
      stream_node = @streams.get_item_parent(item)
      stream = @streams.get_item_data(stream_node)
      dlg = Wx::TextEntryDialog.new(self, "Enter search term",
                                    "Search #{stream.name} stream")
      dlg.show_modal

      Wx::begin_busy_cursor
      @cur_stream = @streams.get_item_data(stream_node)
      stations = search(stream, item, dlg.get_value)
      set_stations(@cur_stream.columns, stations)
      Wx::end_busy_cursor
    end
  end

  def on_station_activated(event)
    selected_node = @streams.get_selection
    active_criteria = nil
    if @streams.get_item_data(selected_node).is_a? String
      active_criteria = @streams.get_item_data(selected_node)
    end
    
    pls_file = @cur_stream.pls_file(active_criteria, event.index)
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

  def set_stations(columns, stations = [])
    @stations.columns = columns
    @stations.item_count = stations.length
    @stations.stations = stations
  end
end
