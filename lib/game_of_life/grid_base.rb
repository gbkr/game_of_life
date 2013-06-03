module GameOfLife
  class GridBase

    attr_reader :grid, :height, :width, :resolution

    def initialize(options)
      @width = options.fetch(:width, 800)
      @height = options.fetch(:height, 800)
      @resolution = options.fetch(:resolution, 10)
    end

    def rows
      height / resolution
    end

    def columns
      width / resolution
    end
  end
end
