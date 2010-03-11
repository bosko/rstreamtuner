require 'options_panel'

class SettingsDialog < Wx::Dialog
  def initialize(parent, settings)
    super(parent, Wx::ID_ANY)
    @settings = settings || Hash.new
    
    sizer = Wx::VBoxSizer.new
    @splitter = Wx::SplitterWindow.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION,
                                       get_size())
    create_settings_tree(@splitter)
 
    @splitter.set_minimum_pane_size(130)
    @splitter.split_vertically(@options,@options.get_item_data(@options.get_root_item()),90)
    sizer.add(@splitter, 0, Wx::ALIGN_CENTER | Wx::ALL, 5)
    
    btn_sizer = create_std_dialog_button_sizer(Wx::OK)
    sizer.add(btn_sizer, 0, Wx::TOP | Wx::BOTTOM | Wx::LEFT, 3)
    self.sizer = sizer
    sizer.fit(self)
  end
  
  def create_settings_tree(splitter)
    @options = Wx::TreeCtrl.new(splitter, Wx::ID_ANY)
    root = @options.add_root("Settings")
    empty_panel = Wx::Panel.new(splitter)
    @options.set_item_data(root, empty_panel)
    
    gen_node = @options.append_item(root, "General")
    gen_panel = OptionsPanel.new(splitter, {:app => @settings[:app]})
    gen_panel.hide
    @options.set_item_data(gen_node, gen_panel)
    
    plugins = @options.append_item(root, "Plugins")
    @options.set_item_data(plugins, empty_panel)

    unless @settings[:streams].nil?
      @settings[:streams].each do |k,v|
        plugin_node = @options.append_item(plugins, k.to_s)
        plugin_panel = OptionsPanel.new(splitter, v)
        plugin_panel.hide
        @options.set_item_data(plugin_node, plugin_panel)
      end
    end
 
    @options.evt_tree_sel_changed(@options.id) { |event| on_node_selected(event) }
    @options.expand_all
  end
 
  def on_node_selected(event)
    win2 = @splitter.get_window_2
    new_win = @options.get_item_data(event.get_item())
    unless new_win.nil? or win2 == new_win
      @splitter.replace_window(win2, new_win)
      win2.hide
      new_win.show
      @splitter.refresh
    end
  end
end
