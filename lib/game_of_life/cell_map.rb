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

      super options

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


    def next_generation
      @unique_cells.clear
      @next_change_list.clear
      change_list.each do |cell|
        process_node(cell[0], cell[1])
      end
      @grid = dup_next_grid
      @change_list = dup_next_change_list
    end 

    private

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
