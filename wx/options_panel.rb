class OptionsPanel < Wx::Panel
  def initialize(parent,options = [])
    super(parent, -1, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE)
    @options = options
    vbox = Wx::VBoxSizer.new
    @options.each do |opt|
      vbox1 = Wx::VBoxSizer.new
      vbox1.add(Wx::StaticText.new(self, -1, opt[:label].to_s), 0)
 
      ctrl = nil
      flags = 0
      if opt[:value].is_a? Fixnum
        ctrl = Wx::SpinCtrl.new(self, -1, opt[:value].to_s)
        flags = Wx::BOTTOM
      else
        ctrl = Wx::TextCtrl.new(self, -1, opt[:value])
        flags = Wx::EXPAND | Wx::BOTTOM
      end
      vbox1.add(ctrl, 0, flags, 3)
 
      vbox.add(vbox1, 0, Wx::EXPAND | Wx::LEFT | Wx::RIGHT, 11)
    end
    set_sizer(vbox)
  end
end
