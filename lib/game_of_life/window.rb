module GameOfLife
  require 'gosu'
  class Window < Gosu::Window

    def initialize(cell_map)
      @cellmap = cell_map
      super @cellmap.width, @cellmap.height, false
      self.caption = "Game of Life"
      @color = Gosu::Color.new(255, 0, 0, 255)
      @resolution = @cellmap.resolution
      @font = Gosu::Font.new(self, "Arial", 18)
      @iterate = ( @cellmap.pattern.nil? ? false : true )
    end

    def update
      @cellmap.next_generation if @iterate
    end

    def draw
      render_cells
      render_iteration
    end

    private

    def render_cells
      @cellmap.on_cells.each do |x, y_values|
        y_values.keys.each do |y|
          draw_cell(x, y)
        end
      end
    end

    def render_iteration
      x ||= @cellmap.width / 2
      y ||= @cellmap.height - 25
      @font.draw(@cellmap.iteration, x, y,
                 1.0, 1.0, 1.0, 0xaaaaaaaa, :default)
    end

    def needs_cursor?
      true
    end

    def button_down(id)
      case id
      when Gosu::KbEscape
        close
      when Gosu::MsLeft
        add_cell
      when Gosu::MsRight, Gosu::KbReturn
        @iterate = true
      end
    end

    def add_cell
      unless @iterate
        x = (mouse_x/@resolution).to_i
        y = (mouse_y/@resolution).to_i
        @cellmap.add_cell(x,y)
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
