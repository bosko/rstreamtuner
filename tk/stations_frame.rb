require 'tkextlib/tktable'

class StationsFrame
  def initialize(root)
    @paned = Tk::Tile::Paned.new(root, :orient=>:horizontal) do |f|
      pack(:side=>:top, :expand=>true, :fill=>:both)
    end
    
    create_stream_list
    create_stations_table
    @paned.add @streams_list
    @paned.add @stations_table
  end

  def add_stream(item)
    @streams_list.insert(:end, item.to_s)
  end

  def load_stream
    index = @streams_list.curselection[0]
    name = @streams_list.get(index)
    @stream = StreamAPI.streams[name].new
    @stream.fetch!
    @ary = add_stations(@stream.stations)
    @stations_table.variable = @ary
  end
  
  def create_stream_list
    @streams_list = TkListbox.new(@paned).pack(:expand=>true)
    @streams_list.bind("ButtonRelease-1") {
      load_stream
    }
  end

  def create_stations_table
    @stations_table = Tk::TkTable.new(:rows=>1, :cols=>4,
                                      :width=>6, :height=>6, 
                                      :titlerows=>1, :titlecols=>0, 
                                      :roworigin=>0, :colorigin=>0, 
                                      :rowstretchmode=>:none, :colstretchmode=>:last,
                                      :selectmode=>:row, :sparsearray=>false)
    
    @stations_table.xscrollbar(TkScrollbar.new)
    @stations_table.yscrollbar(TkScrollbar.new)

    @ary = add_stations
    @stations_table.variable = @ary
  end

  private
  def add_stations(stations = [])
    @stations_table.rows = stations.length + 1
    ary = TkVariable.new_hash
    add_header(ary)
    stations.each_with_index do |station,index|
      ary[index+1,0] = station.name
      ary[index+1,1] = station.now_playing
      ary[index+1,2] = station.genres
      ary[index+1,3] = station.listeners
    end
    ary
  end
  
  def add_header(ary)
    ary[0,0] = 'Name'
    ary[0,1] = 'Now playing'
    ary[0,2] = 'Genres'
    ary[0,3] = 'Listeners'
  end
end
