require 'spec_helper'

module GameOfLife
  describe CellMap do

    describe 'default attributes' do
      let(:cellmap) { CellMap.new }
      subject { cellmap } 

      its(:height) { should == 800 }
      its(:width) { should == 800 }
      its(:resolution) { should == 10 }
      its(:rows) { should == 80 }
      its(:columns) { should == 80 }
    end


    describe 'chosen attributes' do
      options = {width: 600, height: 400, resolution: 5}
      let(:cellmap4) { CellMap.new(options) }
      subject { cellmap4 }

      its(:height) { should == 400 }
      its(:width) { should == 600 }
      its(:resolution) { should == 5 }
      its(:rows) { should == 80 }
      its(:columns) { should == 120 }
    end

    describe 'The grid' do
      it 'should be blank without a pattern' do
        options = { resolution: 10, width: 20, height: 30 }
        CellMap.new(options).grid.should == 
          [[[0, 0], [0, 0]], [[0, 0], [0, 0]], [[0, 0], [0, 0]]]
      end
     
      it 'should contain the pattern when built with a pattern' do
        options = { resolution: 10, width: 30, height: 30, pattern: 'p.arr' }
        CellMap.new(options).grid.should == 
          [[[0, 3], [1, 3], [0, 3]], [[1, 2], [1, 4], [1, 3]], [[0, 2], [0, 4], [1, 2]]]
      end
    end

    describe 'next_generation' do
      it 'should iterate correctly once' do
        options = { resolution: 10, width: 30, height: 30, pattern: 'p.arr' }
        cellmap = CellMap.new(options)

        cellmap.next_generation
        cellmap.grid.should == 
           [[[1, 2], [1, 4], [1, 2]],[[1, 2], [0, 6], [1, 3]],[[0, 1], [0, 3], [1, 1]]]
      end

      it 'should iterate correctly twice' do
        options = { resolution: 10, width: 30, height: 30, pattern: 'p.arr' }
        cellmap = CellMap.new(options) 
        2.times { cellmap.next_generation }
        cellmap.grid.should == 
           [[[1,1], [0,4], [1,1]], [[1,2], [0,5], [1,2]], [[0,2], [1,2], [0,2]]]
      end

      it 'should iterate correcty thrice' do
        options = { resolution: 10, width: 30, height: 30, pattern: 'p.arr' }
        cellmap = CellMap.new(options) 
        3.times { cellmap.next_generation }
        cellmap.grid.should == 
          [[[0,1], [0,2], [0,1]], [[1,1], [0,3], [1,1]], [[0,2], [1,2], [0,2]]]
      end
    
      it 'should increment neighbours correctly' do
        options = { resolution: 10, width: 30, height: 30, pattern: 'p.arr' }
        cellmap = CellMap.new(options)
        cellmap.instance_eval { @next_grid = @grid }
        cellmap.update_neighbours(1, 1, 1)
        cellmap.grid.should ==
           [[[0, 4], [1, 4], [0, 4]], [[1, 3], [1, 4], [1, 4]], [[0, 3], [0, 5], [1, 3]]]
      end

      it 'should decrement neighbours correctly' do
        options = { resolution: 10, width: 30, height: 30, pattern: 'p.arr' }
        cellmap = CellMap.new(options)
        cellmap.instance_eval { @next_grid = @grid }
        cellmap.update_neighbours(1, 1, -1)
        cellmap.grid.should ==
          [[[0, 2], [1, 2], [0, 2]], [[1, 1], [1, 4], [1, 2]], [[0, 1], [0, 3], [1, 1]]]
      end

      it 'should increment top left corner neighours correctly' do
        options = { resolution: 10, width: 30, height: 30, pattern: 'p.arr' }
        cellmap = CellMap.new(options)
        cellmap.instance_eval { @next_grid = @grid }
        cellmap.update_neighbours(0, 0, 1)
        cellmap.grid.should ==
         [[[0, 3], [1, 4], [0, 3]], [[1, 3], [1, 5], [1, 3]], [[0, 2], [0, 4], [1, 2]]]
      end

      it 'should increment bottom left corner neighours correctly' do
        options = { resolution: 10, width: 30, height: 30, pattern: 'p.arr' }
        cellmap = CellMap.new(options)
        cellmap.instance_eval { @next_grid = @grid }
        cellmap.update_neighbours(0, 2, 1)
        cellmap.grid.should ==
          [[[0, 3], [1, 3], [0, 3]], [[1, 3], [1, 5], [1, 3]], [[0, 2], [0, 5], [1, 2]]]
      end

      it 'should increment top right corner neighbours correctly' do
        options = { resolution: 10, width: 30, height: 30, pattern: 'p.arr' }
        cellmap = CellMap.new(options)
        cellmap.instance_eval { @next_grid = @grid }
        cellmap.update_neighbours(2, 0, 1)
        cellmap.grid.should ==
          [[[0, 3], [1, 4], [0, 3]], [[1, 2], [1, 5], [1, 4]], [[0, 2], [0, 4], [1, 2]]]
      end
    end

    it 'should increment bottom right corner neighbours correctly' do
        options = { resolution: 10, width: 30, height: 30, pattern: 'p.arr' }
        cellmap = CellMap.new(options)
        cellmap.instance_eval { @next_grid = @grid }
        cellmap.update_neighbours(2, 2, 1)
        cellmap.grid.should == 
          [[[0, 3], [1, 3], [0, 3]], [[1, 2], [1, 5], [1, 4]], [[0, 2], [0, 5], [1, 2]]]

    end


    #iit 'must be the correct color' do
    #  grid.color.to_s =~ /Gosu::Color/
    #end

    #todo: iterate

  end

  describe 'change list' do
    it 'should initialize correctly' do
      options = { pattern: 'complex.arr' }
      cellmap = CellMap.new(options)
      cellmap.change_list.size.should == 21
    end
  end
end

