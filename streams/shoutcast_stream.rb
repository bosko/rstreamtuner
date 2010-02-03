require "tmpdir"

class ShoutcastStream < StreamAPI
  stream :Shoutcast
  editable :chunk_size, :fetch_limit
  
  def initialize
    super('Shoutcast', 'www.shoutcast.com')

    if config[:columns].nil?
      config[:columns] = []
      config[:columns] << {:header=>"Station", :attr=>:name, :width=>220}
      config[:columns] << {:header=>"Now playing", :attr=>:now_playing, :width=>175}
      config[:columns] << {:header=>"Genres", :attr=>:all_genres, :width=>130}
      config[:columns] << {:header=>"Listeners", :attr=>:listeners, :width=>130}
    end

    config[:chunk_size] = {:label => "Chunk size", :value => 50} if config[:chunk_size].nil?
    config[:fetch_limit] = {:label => "Fetch limit", :value => 100} if config[:fetch_limit].nil?

    save_config
  end
  
  def fetch!
    return @stations[:all] if @stations[:all].length > 0

    fetched_cnt = 0
    http = Net::HTTP.new(url)
    begin
      ref = fetched_cnt * chunk_size + 1
      if ref < fetch_limit
        resp, data = http.get("/directory.jsp?startIndex=#{ref}&numresult=#{chunk_size}&ref=','#{ref}")
        
        value = Nokogiri::HTML.parse(data)
        box_element = value.css('div.boxcenterdir')

        grey_elements = box_element.css('div.dirGreyexpand')
        @stations[:all].concat process_elements(grey_elements) unless grey_elements.nil?
        
        blue_elements = box_element.css('div.dirBlueexpand')
        @stations[:all].concat process_elements(blue_elements) unless blue_elements.nil?
        fetched_cnt += 1
      else
        break
      end
    end while resp.code.to_i == 200
    save_cache

    @stations[:all]
  end

  def search!(criteria)
    return @stations[:search][criteria] if @stations[:search][criteria] and @stations[:search][criteria].length > 0

    @stations[:search][criteria] = Array.new
    
    fetched_cnt = 0
    http = Net::HTTP.new(url)

    begin
      ref = fetched_cnt * chunk_size + 1
      return unless ref < fetch_limit
      
      search_url = "/directory/searchKeyword.jsp?startIndex=#{ref}&numresult=#{chunk_size}&mode=listener&searchCrit=simple&s=#{criteria}"
      resp, data = http.get(search_url)
      value = Nokogiri::HTML.parse(data)
      greys = value.css('div.dirGreyexpand')
      @stations[:search][criteria].concat process_elements(greys) unless greys.nil?
      
      blues = value.css('div.dirBlueexpand')
      @stations[:search][criteria].concat process_elements(blues) unless blues.nil?
      fetched_cnt += 1
    end while resp.code == 200
    save_cache
    @stations[:search][criteria]
  end
  
  def chunk_size
    config[:chunk_size][:value]
  end

  def chunk_size=(size)
    config[:chunk_size][:value] = size
  end
  
  def fetch_limit
    config[:fetch_limit][:value]
  end

  def fetch_limit=(limit)
    config[:fetch_limit][:value] = limit
  end

  def pls_file(search_criteria, index)
    active_stations = []
    if search_criteria.nil?
      active_stations = @stations[:all]
    else
      active_stations = @stations[:search][search_criteria]
    end
    
    id = active_stations[index][:id]
    http = Net::HTTP.new('yp.shoutcast.com')
    resp, data = http.get("/sbin/tunein-station.pls?id=#{id}")

    fpath = File.join(Dir.tmpdir, "sc_#{id}.pls")
    File.open(fpath, 'w') do |f|
      f.write data
    end
    fpath
  end

  private
  def process_elements(elements)
    fetched = Array.new
    return unless elements.is_a? Nokogiri::XML::NodeSet
    elements.each do |elem|
      begin
        station = Hash.new
        station[:id] = elem.attributes['id'].value.match(/\d+/)[0]
        station[:name] = elem.css('a.dirStationCntexpand')[0].attributes['title'].value
        station[:url] = elem.css('a.dirStationCntexpand')[0].attributes['href'].value
        station[:now_playing] = elem.css('div.dirNowPlayingCntexpand')[0].attributes['title'].value
        station[:genres] = []
        elem.css('div.dirGenreDiv').css('a').each do |g|
          station[:genres] << g.text
        end
        station[:all_genres] = station[:genres].join ', '
        station[:listeners] = elem.css('div.dirListenersDiv').css('span').map {|x| x.text}.join(' ')
        
        fetched << station
      rescue
      end
    end
    fetched
  end
end
