require 'tkextlib/tktable'

class StationsFrame
  def initialize(root)
    @paned = Tk::Tile::Paned.new(root, :orient=>:horizontal) do |f|
      pack(:side=>:top, :expand=>true, :fill=>:both)
    end

    @ary = TkVariable.new_hash
    @ary[0,0] = 'Name'
    @ary[0,1] = 'Now playing'
    @ary[0,2] = 'Genres'
    @ary[0,3] = 'Listeners'
    @streams_list = TkListbox.new(@paned).pack(:expand=>true)
    @stations_table = Tk::TkTable.new(:rows=>1, :cols=>4,
                            :width=>6, :height=>6, 
                            :titlerows=>1, :titlecols=>0, 
                            :roworigin=>0, :colorigin=>0, 
                            :rowstretchmode=>:none, :colstretchmode=>:last,
                            :selectmode=>:extended, :sparsearray=>false)    

    @stations_table.variable = @ary
    @paned.add @streams_list
    @paned.add @stations_table
  end

  def add_stream(item)
    @streams_list.insert(:end, item.to_s)
  end
end
