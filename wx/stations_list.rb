class StationsList < Wx::ListCtrl
  attr_accessor :stations
  
  def initialize(parent, id)
    super(parent, id, :style => Wx::LC_REPORT | Wx::LC_VIRTUAL)
    @even_attr = Wx::ListItemAttr.new
    @even_attr.set_background_colour(Wx::Colour.new('LIGHT BLUE'))
                                     
    insert_column(0, "Station")
    insert_column(1, "Now listening")
    insert_column(2, "Genres")
    insert_column(3, "Listeners")
    set_column_width(0,175)
    set_column_width(1,175)
    set_column_width(2,175)
    set_column_width(3,175)
  end

  def on_get_item_text(item, col)
    text = ''
    if @stations
      case col
      when 0
        text = @stations[item].name
      when 1
        text = @stations[item].now_playing
      when 2
        text = @stations[item].genres.join(', ')
      when 3
        text = @stations[item].listeners
      end
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

