require 'options_panel'

class SettingsDialog < Wx::Dialog
  def initialize(parent)
    super(parent, Wx::ID_ANY)
    sizer = Wx::VBoxSizer.new
    @splitter = Wx::SplitterWindow.new(self,Wx::ID_ANY, Wx::DEFAULT_POSITION,
                                       get_size())
    create_settings_tree(@splitter)
 
    @splitter.set_minimum_pane_size(100)
    @splitter.split_vertically(@options,@options.get_item_data(@options.get_root_item()),90)
    sizer.add(@splitter, 0, Wx::ALIGN_CENTER | Wx::ALL, 5)
    
    btn_sizer = create_std_dialog_button_sizer(Wx::OK | Wx::CANCEL)
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
    opts = []
    opts << {:label=>"Path to file", :value=>"c:/"}
    opts << {:label=>"Volume", :value=>35}
    opts << {:label=>"Link", :value=>'www.shoutcast.com'}
    opts << {:label=>"Paragraph", :value=>'A little bit longer text to display'}
    opts << {:label=>"Number", :value=>14}
    opts << {:label=>"Bitrate", :value=>168}
    gen_panel = OptionsPanel.new(splitter, opts)
    gen_panel.hide
    @options.set_item_data(gen_node, gen_panel)
    
    plugins = @options.append_item(root, "Plugins")
    @options.append_item(plugins, "First")
    @options.append_item(plugins, "Second")
 
    @options.expand(root)
    @options.evt_tree_sel_changed(@options.id) { |event| on_node_selected(event) }
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
