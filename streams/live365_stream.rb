class Live365Stream < StreamAPI
  stream :Live365
  def initialize
    super('Live365', 'www.live365.com', 100, 500)
  end
end
