require 'rbconfig'
require 'stations_list'
require 'settings_dialog'

include Wx

class MainFrame < Wx::Frame

  CLOSE_APP = 103
  SETTINGS_APP = 104

  STREAMS_LIST = 1000
  STATIONS_LIST = 1001

  def initialize
    super(nil, -1, "Ruby Stream Tuner",
          DEFAULT_POSITION, Size.new(900,500), DEFAULT_FRAME_STYLE)
    create_status_bar
    create_menu
    @tool_bar = create_tool_bar
    add_tools(@tool_bar)
    splitter = Wx::SplitterWindow.new(self,-1)

    create_streams_tree(splitter)
    create_stations_list(splitter)

    icons_path = File.expand_path(File.join(File.dirname(__FILE__), 'icons'))
    self.icon = Wx::Icon.new(File.join(icons_path, 'music.png'), Wx::BITMAP_TYPE_PNG)
    splitter.set_minimum_pane_size(20)
    splitter.split_vertically(@streams_tree,@stations,170)
  end

  def create_menu
    menu_bar = Wx::MenuBar.new

    file_menu = Wx::Menu.new
    file_menu.append(CLOSE_APP, "&Close", "Close application")
    file_menu.append(SETTINGS_APP, "&Settings", "Application settings")
    
    menu_bar.append(file_menu, '&File')
    evt_menu(CLOSE_APP) {|event| close_window(event)}
    evt_menu(SETTINGS_APP) {|event| on_settings}
    set_menu_bar(menu_bar)
  end

  def add_tools(tool_bar)
    icons_path = File.expand_path(File.join(File.dirname(__FILE__), 'icons'))
    play_bmp = Wx::Bitmap.new(File.join(icons_path, 'play.png'), Wx::BITMAP_TYPE_PNG)
    refresh_bmp = Wx::Bitmap.new(File.join(icons_path, 'refresh.png'), Wx::BITMAP_TYPE_PNG)
    delete_bmp = Wx::Bitmap.new(File.join(icons_path, 'delete.png'), Wx::BITMAP_TYPE_PNG)

    @tools = Hash.new
    
    play_tool = tool_bar.add_item(play_bmp, :label => 'Play', :short_help => 'Play selected station')
    @tools[:play] = play_tool
    evt_update_ui(play_tool) { |event| on_update_ui(event) }
    tool_bar.evt_tool(play_tool.id) do |event|
      if @stations.get_selections.length > 0
        on_station_activated(@stations.get_selections[0])
      end
    end
    
    refresh_tool = tool_bar.add_item(refresh_bmp,
                                     :label => 'Refresh',
                                     :short_help => 'Refresh selected category')
    @tools[:refresh] = refresh_tool
    evt_update_ui(refresh_tool) { |event| on_update_ui(event) }
    tool_bar.evt_tool(refresh_tool.id) do |event|
      selected = @streams_tree.selection
      data = @streams_tree.get_item_data(selected)
      if data.is_a? StreamAPI
        data.clear_stations
        on_node_selected(selected)
      elsif data.is_a? String
        Wx::begin_busy_cursor
        @cur_stream.clear_search(data)
        stations = @cur_stream.search!(data)
        @cur_stream.save_cache
        set_stations(@cur_stream.columns, stations)
        Wx::end_busy_cursor
      end
    end
    
    delete_tool = tool_bar.add_item(delete_bmp, :label => 'Delete', :short_help => 'Delete search term')
    @tools[:delete] = delete_tool
    evt_update_ui(delete_tool) { |event| on_update_ui(event) }
    tool_bar.evt_tool(delete_tool.id) do |event|
      selected = @streams_tree.selection
      data = @streams_tree.get_item_data(selected)
      if data.is_a? String
        search_node = @streams_tree.get_item_parent(selected)
        stream_node = @streams_tree.get_item_parent(search_node)
        @cur_stream.remove_search data
        @cur_stream.save_cache
        @streams_tree.select_item stream_node
        @streams_tree.delete selected
      end
    end

    tool_bar.realize
  end
  
  def create_streams_tree(splitter)
    @streams = []
    @streams_tree = Wx::TreeCtrl.new(splitter, STREAMS_LIST)
    create_image_list(@streams_tree)
    root = @streams_tree.add_root("Streams", @tree_icons[:music])
    StreamAPI.streams.each do |name,stream_klass|
      stream_node = @streams_tree.append_item(root, name,
                                         @tree_icons[:folder_closed],
                                         @tree_icons[:folder_opened])
      stream = stream_klass.new
      @streams << stream
      
      # Store stream in the node's data
      @streams_tree.set_item_data(stream_node, stream)
      search_node = @streams_tree.append_item(stream_node, "Search", @tree_icons[:search])
      stream.search_terms.each do |search_term|
        term_node = @streams_tree.append_item(search_node, search_term, @tree_icons[:search_folder])
        # Store search term in the node's data
        @streams_tree.set_item_data(term_node, search_term)
      end
    end
    @streams_tree.expand(root)
    @streams_tree.evt_tree_sel_changed(@streams_tree.id) { |event| on_node_selected(event.get_item()) }
  end

  def create_stations_list(splitter)
    @stations = StationsList.new(splitter, STATIONS_LIST)
    @stations.evt_list_item_activated(@stations.id) { |event| on_station_activated(event.index) }
    @stations.evt_list_col_end_drag(@stations.id) { |event| on_column_width_changed(event) } 
  end
  
  def close_window(event)
    event.skip
    close(true)
  end

  def on_settings
    sett = Hash.new
    sett[:app] = {:label => "Player", :value => "audacious2"}

    streams_sett = Hash.new
    @streams.each do |stream|
      streams_sett[stream.name] = stream.editable_settings unless stream.editable_settings.length == 0
    end
    sett[:streams] = streams_sett

    sd = SettingsDialog.new(self, sett)
    sd.show_modal
    @streams.each do |stream|
      stream.save_config
    end
  end

  def search(stream, search_node, search_term)
    stations = Array.new
    if stream.nil? or !stream.is_a?(StreamAPI) or search_term.empty?
      return stations
    end

    @streams_tree.get_children(search_node).each do |criteria_node|
      if @streams_tree.get_item_data(criteria_node) == search_term
        # If we already have node with this search term select it and
        # return
        @streams_tree.select_item(criteria_node, true)
        return stations
      end
    end

    criteria_node = @streams_tree.append_item(search_node, search_term, @tree_icons[:search_folder])
    @streams_tree.set_item_data(criteria_node, search_term)

    @streams_tree.expand(search_node)
    @streams_tree.select_item(criteria_node, true)

    stations = stream.search! search_term
    stream.save_cache
    stations
  end

  def on_node_selected(item)
    if item == @streams_tree.get_root_item
      set_stations(nil)
      return
    end

    data = @streams_tree.get_item_data(item)
    if data and data.is_a? StreamAPI
      Wx::begin_busy_cursor
      @cur_stream = data
      fetched = @cur_stream.fetch!
      set_stations(@cur_stream.columns, fetched)
      get_status_bar().push_status_text "Number of stations: #{fetched.length}"
      Wx::end_busy_cursor
    elsif !data.nil?
      Wx::begin_busy_cursor
      search_node = @streams_tree.get_item_parent(item)
      stream_node = @streams_tree.get_item_parent(search_node)

      @cur_stream = @streams_tree.get_item_data(stream_node)
      set_stations(@cur_stream.columns, @cur_stream.search!(data))
      Wx::end_busy_cursor
    else
      stream_node = @streams_tree.get_item_parent(item)
      stream = @streams_tree.get_item_data(stream_node)
      dlg = Wx::TextEntryDialog.new(self, "Enter search term",
                                    "Search #{stream.name} stream")
      dlg.show_modal

      Wx::begin_busy_cursor
      @cur_stream = @streams_tree.get_item_data(stream_node)
      stations = search(stream, item, dlg.get_value)
      set_stations(@cur_stream.columns, stations)
      Wx::end_busy_cursor
    end
  end

  def on_station_activated(station_index)
    selected_node = @streams_tree.get_selection
    active_criteria = nil
    if @streams_tree.get_item_data(selected_node).is_a? String
      active_criteria = @streams_tree.get_item_data(selected_node)
    end
    
    pls_file = @cur_stream.pls_file(active_criteria, station_index)
    return unless File.exist? pls_file
    Wx::begin_busy_cursor
    if Config::CONFIG['host_os'] =~ /mswin|mingw/
      # Windows player
      IO.popen "c:/Program Files (x86)/AIMP2/AIMP2.exe #{pls_file}"
    else
      IO.popen "audacious2 #{pls_file} 2>&1 1>/dev/null"
    end
    
    Wx::end_busy_cursor
  end

  def on_column_width_changed(event)
    @cur_stream.column_width(event.get_column, @stations.column_width(event.get_column))
  end

  def on_update_ui(event)
    case event.id
    when @tools[:play].id
      event.enable(@stations.get_selections.length > 0)
    when @tools[:refresh].id
      selected_node = @streams_tree.selection
      if 0 == selected_node or @streams_tree.get_item_data(selected_node).nil?
        event.enable(false)
      else
        event.enable(true)
      end
    when @tools[:delete].id
      selected_node = @streams_tree.selection
      if 0 != selected_node and @streams_tree.get_item_data(selected_node).is_a? String
        event.enable(true)
      else
        event.enable(false)
      end
    end
  end
  
  def set_stations(columns, stations = [])
    @stations.columns = columns
    @stations.item_count = stations.length
    @stations.stations = stations
  end

  def create_image_list(tree_ctrl)
    icons_path = File.expand_path(File.join(File.dirname(__FILE__), 'icons'))
    images = Wx::ImageList.new(16, 16, true)
    @tree_icons = Hash.new
    @tree_icons[:music] = images.add(Wx::Bitmap.new(File.join(icons_path, 'music.png'),
                                                          Wx::BITMAP_TYPE_PNG))
    @tree_icons[:folder_closed] = images.add(Wx::Bitmap.new(File.join(icons_path, 'folder_closed.png'),
                                                          Wx::BITMAP_TYPE_PNG))
    @tree_icons[:folder_opened] = images.add(Wx::Bitmap.new(File.join(icons_path, 'folder_open.png'),
                                                          Wx::BITMAP_TYPE_PNG))
    @tree_icons[:search] = images.add(Wx::Bitmap.new(File.join(icons_path, 'search.png'),
                                                          Wx::BITMAP_TYPE_PNG))
    @tree_icons[:search_folder] = images.add(Wx::Bitmap.new(File.join(icons_path, 'folder_search.png'),
                                                       Wx::BITMAP_TYPE_PNG))
    tree_ctrl.image_list = images
  end

  def app_settings
    sett = Array.new
    sett << {:label => "Player", :value => "audacious2"}
  end
end
