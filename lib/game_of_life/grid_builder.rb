module GameOfLife
  class GridBuilder < GridBase

    attr_reader :options

    def initialize(options)
      @options = options
      super options
    end

    def build_grid
      @grid = build
      if options[:pattern]
        add_pattern(load_pattern(options[:pattern]))
      end
      @grid
    end

    private

    def build
      Matrix.build(rows, columns) {|row, col|
        # [on|off, neighbour count]
        [0, 0]    
      }.to_a
    end

    def add_pattern(pattern)
      x_start, y_start = centered_coordinates(pattern)
      pattern.each.with_index do |p_row, p_row_i|
        p_row.each.with_index do |details, cell_i|
          grid[p_row_i + y_start][cell_i + x_start] = details
        end
      end
    end

    def centered_coordinates(pattern)
      pattern_columns = pattern[0].size
      pattern_rows = pattern.size
      x_start = columns / 2 - pattern_columns / 2
      y_start = rows / 2 - pattern_rows / 2
      [x_start, y_start]
    end

    # need to take in a life file and return a nice array of arrays of arrays... 
    def load_pattern(file)
      file = File.new(file, 'r')
      pattern_attributes = pattern_attributes(file)
      file.close
      file = File.new(file, 'r')
      pattern = cellmap_with_pattern(file, pattern_attributes)
      file.close
      add_pattern(pattern)
      update_neighbour_count
    end

    def pattern_attributes(file)
      x = []
      y = []
      while (line = file.gets)
        line.strip!
        if line =~ /#P/
          y_count = 0
          coordinates = line.sub('#P ', '').split(' ')
        elsif line =~ /\A[\*\.]*\z/
          y_count += 1
          y << y_count + coordinates[1].to_i
          x << line.length + coordinates[0].to_i
        end
      end

      attributes = {}

      attributes[:width] = x.map {|e| e.abs}.max * 2
      attributes[:height] = y.map {|e| e.abs}.max * 2
      attributes[:x_offset] = x.min.abs + 1
      attributes[:y_offset] = y.min.abs + 1
      attributes
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

    def cellmap_with_pattern(file, pattern_attributes)
      puts pattern_attributes.inspect
      map = Matrix.build(pattern_attributes[:height], pattern_attributes[:width]) {|row, col|
        # [on|off, neighbour count]
        [0, 0]    
      }.to_a

      while (line = file.gets)
        line.strip!
        next if line.empty?
        if line =~ /#P/
          segments = line.split(' ')
          node_x = segments[1].to_i
          node_y = segments[2].to_i
        end
        if line =~ /\A[\*\.]*\z/
          line.split(//).each.with_index do |state, state_i|
          if state == '*'
            y = node_y + pattern_attributes[:y_offset]
            x = node_x + pattern_attributes[:x_offset] + state_i 
            map[y][x][0] = 1
          end
        end
        node_y += 1
        end
      end
      map
    end
  end
end
