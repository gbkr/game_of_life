module GameOfLife
  class GridBuilder < GridBase

    attr_reader :options

    def initialize(options)
      @options = options
      super options
    end

    def build_grid
      @grid = build_matrix(rows, columns)
      load_pattern if pattern
      @grid
    end

    private

    def build_matrix(rows, columns)
      Matrix.build(rows, columns) {|row, col|
        [0, 0]  # [ on/off | live neighbour count ]
      }.to_a
    end

    def add_pattern(pattern)
      x_start, y_start = centered_coordinates(pattern)
      pattern.each.with_index do |p_row, p_row_i|
        p_row.each.with_index do |details, cell_i|
          grid[p_row_i + y_start][cell_i + x_start] = details
        end
      end
      grid
    end

    def load_pattern
      pattern = cellmap_with_pattern(pattern_data)
      add_pattern(pattern)
      update_neighbour_count
    end

    def centered_coordinates(pattern)
      pattern_columns = pattern[0].size
      pattern_rows = pattern.size
      x_start = columns / 2 - pattern_columns / 2
      y_start = rows / 2 - pattern_rows / 2
      [x_start, y_start]
    end


    # generate a grid from the calculated attributes of the pattern
    # load the pattern into this grid
    def cellmap_with_pattern(pattern_data)
      check_pattern_size(pattern_data)
      pattern_map = build_matrix(pattern_data[:height],
                                 pattern_data[:width])

      pattern_data[:pattern].each {|x, values| 
        values.each do |y, cells|
          cells.split(//).each.with_index do |state, state_i|
            x_pos = x + state_i + pattern_data[:x_offset]
            y_pos = y + pattern_data[:y_offset]
            pattern_map[y_pos][x_pos][0] = 1 if state == '*'
          end
        end
      }
      pattern_map
    end

    def read_pattern_file
      if File.exists?(pattern)
        File.open(pattern, 'r') do |file|
          yield(file)
        end
      else
        raise "File not found: #{pattern}"
      end
    end


    def pattern_data
      x,y = [], []
      pattern, attributes = {}, {}

      read_pattern_file { |file|
        while (line = file.gets)
          line.strip!
          if line =~ /#P/
            y_count = 0
            block = block_location(line)
            x << block.x
          elsif line =~ /\A[\*\.]*\z/
            y << y_count + block.y
            x << line.length + block.x
            pattern[block.x] ||= {}
            pattern[block.x][block.y + y_count] = line
            y_count += 1
          end
        end }

      attributes[:width] = (x.max - x.min) + 2
      attributes[:height] = (y.max - y.min) + 2
      attributes[:x_offset] = x.min * -1
      attributes[:y_offset] = y.min * -1
      attributes[:pattern] = pattern
      attributes
    end

    Block = Struct.new(:x, :y)
    def block_location(line)
      coordinates = line.sub('#P ', '').split(' ').map { |e| e.to_i }
      Block.new(coordinates[0], coordinates[1])
    end

    def update_neighbour_count
      grid.each.with_index do |row, y|
        row.each.with_index do |cell, x|
          grid[y][x][1] = live_neighbours(x,y)
        end
      end
    end

    def live_neighbours(x, y)
      %i[top top_right right bottom_right bottom bottom_left left top_left].map { |position| self.send(position, x, y) }.reduce(:+)
    end

    def top(x,y); check(x, y-1); end
    def top_right(x,y); check(x+1, y-1); end
    def right(x,y); check(x+1, y); end
    def bottom_right(x,y); check(x+1, y+1); end
    def bottom(x,y); check(x, y+1); end
    def bottom_left(x,y); check(x-1, y+1); end
    def left(x,y); check(x-1, y); end
    def top_left(x,y); check(x-1, y-1); end

    def check(x,y)
      return 0 if y < 0 or y >= rows
      return 0 if x < 0 or x >= columns
      grid[y][x][0]
    end

    def check_pattern_size(pattern)
      unless grid.size >= pattern[:height] and
        grid[0].size >= pattern[:width].size
        raise "Pattern too large for default grid. Please choose a cellmap larger " +
          "than #{pattern[:width]} columns and #{pattern[:height]} rows."
      end
    end
  end
end
