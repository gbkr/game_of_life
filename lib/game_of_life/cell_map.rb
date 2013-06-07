module GameOfLife
  class CellMap < GridBase

    attr_reader :change_list, :on_cells

    def initialize(options={})
      @grid = grid_builder(options)
      @next_grid = dup_grid
      @next_change_list = []
      @unique_cells = {}
      @on_cells = {}
      @change_list = create_change_list
      @iteration = 0
      super options
      find_on_cells
    end

    def next_generation
      ensure_frame_rate {
        clear_prev_gen_vars
        process_change_list
        update_new_generation
        @iteration += 1
      }
    end

    def iteration
      @iteration.to_s
    end

    def add_cell(x,y)
      toggle_on_cells(x,y)
      toggle_neighbours(x,y)
      @grid = dup_next_grid
      @change_list = create_change_list
    end

    private

    def ensure_frame_rate
      yield and return unless freq
      t1 = Time.now
      yield
      duration = Time.now - t1
      unless duration > freq
        sleep freq - duration
      end
    end

    def clear_prev_gen_vars
      @unique_cells.clear
      @next_change_list.clear
    end

    def process_change_list
      change_list.each do |cell|
        process_node(cell[0], cell[1])
      end
    end

    def update_new_generation
      @grid = dup_next_grid
      @change_list = dup_next_change_list
    end

    def find_on_cells
      grid.each.with_index do |row, y|
        row.each.with_index do |cell, x|
          review_for_on_cells(x,y)
        end
      end
    end

    def review_for_on_cells(x,y)
      if @next_grid[y][x][0]==1
        if @on_cells[x]
          return if @on_cells[x][y]
          @on_cells[x].merge!({ y => true })
        else
          @on_cells.merge!( x => { y => true })
        end
      else
        if @on_cells[x]
          @on_cells[x].delete(y) if @on_cells[x][y]
        end
      end
    end

    def toggle_on_cells(x, y)
      if @on_cells[x]
        if @on_cells[x][y]
          @on_cells[x].delete(y)
        else
          @on_cells[x].merge!({ y => true}) 
        end
      else
        @on_cells.merge!(x => { y => true} )
      end
    end

    def toggle_neighbours(x,y)
      if @next_grid[y][x][0] == 1
        @next_grid[y][x][0] = 0
        update_neighbours(x, y, -1)
      else
        @next_grid[y][x][0] = 1
        update_neighbours(x, y, 1)
      end
    end

    def grid_builder(options)
      GridBuilder.new(options).build_grid
    end

    def review_for_changelist(x,y)
      if @unique_cells[x]
        return if @unique_cells[x][y]
        @unique_cells[x].merge!({ y => true })
      else
        @unique_cells.merge!( x => { y => true })
      end
      @next_change_list << [x,y]
    end

    def process_node(x, y)
      cell = cell_detail(x, y)
      if cell.alive?
        unless @rules.survival.include?(cell.neighbours)
          state = 0
          update_neighbours(x, y, -1)
        end
      else
        if @rules.birth.include?(cell.neighbours)
          state = 1
          update_neighbours(x, y, 1)
        end
      end

      if state
        @next_grid[y][x][0] = state
        review_for_changelist(x, y)
        review_for_on_cells(x,y)
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

    def update_cell(*opts)
      wrap ? update_with_wrap(*opts) : update_without_wrap(*opts)
    end

    def update_with_wrap(y,x, value)
      y = 0 if y >=rows
      x = 0 if x >=columns
      y = rows - 1 if y < 0
      x = columns - 1 if x < 0
      @next_grid[y][x][1] += value 
      review_for_changelist(x, y)
    end

    def update_without_wrap(y,x, value)
      return if y < 0 or y >= rows
      return if x < 0 or x >= columns
      @next_grid[y][x][1] += value 
      review_for_changelist(x, y)
    end

    Cell = Struct.new(:alive?, :neighbours, :x, :y)
    def cell_detail(x,y)
      target_cell = grid[y][x]
      alive = (target_cell[0] == 1 ? true : false)
      Cell.new(alive, target_cell[1], x, y)
    end

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
