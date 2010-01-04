class StationsList < Wx::ListCtrl
  attr_accessor :stations
  
  def initialize(parent, id)
    super(parent, id, :style => Wx::LC_REPORT | Wx::LC_VIRTUAL)
    @even_attr = Wx::ListItemAttr.new
    @even_attr.set_background_colour(Wx::Colour.new('LIGHT BLUE'))
  end

  def columns=(columns)
    clear_all
    return unless columns.is_a? Array
    @columns = columns
    @columns.each_with_index do |col, idx|
      insert_column(idx, col[:header])
    end
  end
  
  def on_get_item_text(item, col)
    text = ''
    if @stations and col < @stations.length
      text = @stations[item].send(@columns[col][:attr])
    end

    text
  end

  def on_get_item_column_image(item, col)
    return -1
  end

  def on_get_item_attr(item)
    if item % 2 == 0
      return @even_attr
    end
  end
end

