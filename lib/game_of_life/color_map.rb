class ColorMap

  def initialize
    @colors = [
      Gosu::Color.new(255,153,0),
      Gosu::Color.new(255,214,153),
      Gosu::Color.new(255,193,101),
      Gosu::Color.new(255,173,51),
      Gosu::Color.new(255,153,0),
      Gosu::Color.new(204,122,0),
      Gosu::Color.new(253,91,0),
      Gosu::Color.new(101,61,0),
      Gosu::Color.new(50,30,0)
    ]
  end

  def color(n)
    @colors[n]
  end
end
