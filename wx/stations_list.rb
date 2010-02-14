class StationsList < Wx::ListCtrl
  attr_accessor :stations

  ASCENDING = -1
  DESCENDING = 1
  
  def initialize(parent, id)
    super(parent, id, :style => Wx::LC_REPORT | Wx::LC_VIRTUAL | Wx::LC_VRULES | Wx::LC_SINGLE_SEL)
    @even_attr = Wx::ListItemAttr.new
    @even_attr.set_background_colour(Wx::Colour.new('LIGHT BLUE'))
  end

  def columns=(columns)
    clear_all
    return unless columns.is_a? Array
    @columns = columns
    @columns.each_with_index do |col, idx|
      insert_column(idx, col[:header])
      evt_list_col_click(id) do |event|
        case @sort_order
        when ASCENDING
          @stations.reverse!
          @sort_order = DESCENDING
        else
          @stations.sort! do |a, b|
            a[@columns[event.get_column][:attr]] <=> b[@columns[event.get_column][:attr]]
          end
          @sort_order = ASCENDING
        end
      end
      
      set_column_width(idx, col[:width]) if col[:width]
    end
  end
  
  def on_get_item_text(item, col)
    text = ''
    if @stations and item < @stations.length
      text = @stations[item][@columns[col][:attr]]
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

  def column_width(idx)
    get_column_width(idx)
  end
end

