module GameOfLife
  require 'gosu'
  class Window < Gosu::Window

    def initialize(cell_map)
      @color = Gosu::Color.new(255, 0, 0, 255)
      @cellmap = cell_map
      @resolution = @cellmap.resolution
      super @cellmap.width, @cellmap.height, false
    end

    def update
      @cellmap.next_generation
    end

    def draw
      @cellmap.on_cells.each do |x, y_values|
        y_values.keys.each do |y|
          draw_cell(x, y)
        end
      end
    end
    
    
   # def draw2
      #@cellmap.grid.each_index do |y|
        #@cellmap.grid[y].each_index do |x|
          #draw_cell(x, y) if @cellmap.grid[y][x][0] == 1
        #end
      #end
    #end

    private

    def needs_cursor?
      true
    end

    def button_down(id)
      if id == Gosu::KbEscape
        close
      end
    end

    def draw_cell(x, y)
      x = x * @resolution
      y = y * @resolution
      draw_quad(x,               y,               @color,
                x + @resolution, y,               @color,
                x,               y + @resolution, @color,
                x + @resolution, y + @resolution, @color,
                0
               )
    end
  end
end