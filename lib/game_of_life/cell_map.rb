module GameOfLife
  class CellMap

    attr_reader :grid, :width, :height, :resolution, :change_list

    def initialize(options={})
      @width = options.fetch(:width, 800)
      @height = options.fetch(:height, 800)
      @resolution = options.fetch(:resolution, 10)
      @grid = build
      if options[:pattern]
        add_pattern(load_pattern(options[:pattern]))
      end
      @next_grid = dup_grid
      @change_list = create_change_list
      @next_change_list = []
      @h = {}
    end

    def next_generation
      @h.clear
      @next_change_list.clear
      @change_list.each do |cell|
        process_node(cell[0], cell[1])
      end
      @grid = dup_next_grid
      @change_list = dup_next_change_list
    end 

    private

    def review_for_changelist(x,y)
      if @h.fetch(x, nil)
        if @h[x].fetch(y, nil)
          return
        else
          @h[x].merge!({y => true})
        end
      else
        @h.merge!(x => { y => true})
      end
      @next_change_list << [x,y]
    end


    # update the state of (x,y)
    # if the state changes, update the neighbours
    # eg. a cell state changes (based on it's state and neighbour count), then either all neighbouring
    # cells have their neighbour count incremented, or decremented
    def process_node(x, y)
      cell = cell_detail(x, y)
      if cell.alive?
        unless cell.neighbours.between?(2, 3)
          state = 0
          update_neighbours(x, y, -1)
        end
      else
        if cell.neighbours == 3
          state = 1
          update_neighbours(x, y, 1)
        end
      end
      if state
        @next_grid[y][x][0] = state
        review_for_changelist(x, y)
      end
    end

    def update_neighbours(x, y, value)
      update_cell(y-1, x,   value)
      update_cell(y-1, x+1, value)
      update_cell(y  , x+1, value)
      update_cell(y+1, x+1, value)
      update_cell(y+1, x,   value)
      update_cell(y+1, x-1, value)
      update_cell(y  , x-1, value)
      update_cell(y-1, x-1, value)
    end


    def update_cell(y,x, value)
      y = 0 if y >=rows
      x = 0 if x >=columns
      y = rows - 1 if y < 0
      x = columns - 1 if x < 0
      @next_grid[y][x][1] += value 
      review_for_changelist(x, y)
    end


    #  def update_cell_no_wrap(y,x, value)
    #return if y < 0 or y >= rows
    #return if x < 0 or x >= columns
    #@next_grid[y][x][1] += value 
    #review_for_changelist(x, y)
    #end

    def rows
      height / resolution
    end

    def columns
      width / resolution
    end

    def build
      Matrix.build(rows, columns) {|row, col|
        # [on|off, neighbour count]
        [0, 0]    
      }.to_a
    end

    Cell = Struct.new(:alive?, :neighbours, :x, :y)
    def cell_detail(x,y)
      target_cell = grid[y][x]
      alive = (target_cell[0] == 1 ? true : false)
      Cell.new(alive, target_cell[1], x, y)
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
    #  puts "x: #{x}, y: #{y}"
    #  puts grid[y][x]
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

    # def load_pattern(file)
    #   return unless file
    #   JSON.parse(File.read(file))
    # end

    def create_change_list
      change_list = []
      grid.each.with_index do |row, y|
        row.each.with_index do |cell, x|
          if cell.reduce(:+) > 0
            change_list << [x,y]
          end
        end
      end
      change_list
    end

    def dup_grid
      grid.map { |row|
        row.map { |e| e.dup } }
    end

    def dup_next_grid
      @next_grid.map { |row|
        row.map {|e| e.dup } }
    end

    def dup_change_list
      change_list.map {|e| e.dup }
    end

    def dup_next_change_list
      @next_change_list.map {|e| e.dup }
    end
  end
end
