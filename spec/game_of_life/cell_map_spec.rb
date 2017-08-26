require 'spec_helper'

module GameOfLife
  describe CellMap do

    describe 'default attributes' do
      let(:cellmap) { CellMap.new }
      subject { cellmap }

      it 'initializes with the correct defaults' do
        expect(subject.height).to eq(800)
        expect(subject.width).to eq(800)
        expect(subject.resolution).to eq(10)
        expect(subject.rows).to eq(80)
        expect(subject.columns).to eq(80)
      end
    end


    describe 'chosen attributes' do
      options = {width: 600, height: 400, resolution: 5}
      let(:cellmap4) { CellMap.new(options) }
      subject { cellmap4 }

      it 'initializes correctly with user supplied attributes' do
        expect(subject.height).to eq(400)
        expect(subject.width).to eq(600)
        expect(subject.resolution).to eq(5)
        expect(subject.rows).to eq(80)
        expect(subject.columns).to eq(120)
      end
    end

    describe 'The grid' do
      it 'is blank without a pattern' do
        options = { resolution: 10, width: 20, height: 30 }
        expect(CellMap.new(options).grid).to eq([
          [[0, 0], [0, 0]], [[0, 0], [0, 0]], [[0, 0], [0, 0]]])
      end

      it 'contains the pattern when built with a pattern' do
        options = { resolution: 10, width: 50, height: 50, pattern: RPENTO }
        expect(CellMap.new(options).grid).to eq([
            [[0, 0], [0, 1], [0, 2], [0, 2], [0, 1]],
            [[0, 1], [0, 3], [1, 3], [1, 2], [0, 1]],
            [[0, 1], [1, 3], [1, 4], [0, 4], [0, 1]],
            [[0, 1], [0, 3], [1, 2], [0, 2], [0, 0]],
            [[0, 0], [0, 1], [0, 1], [0, 1], [0, 0]]
        ])
      end
    end

    describe 'next_generation' do
      it 'iterates correctly once' do
        options = { resolution: 10, width: 50, height: 50, pattern: RPENTO }
        cellmap = CellMap.new(options)

        cellmap.next_generation
        expect(cellmap.grid).to eq([
            [[0, 1], [0, 2], [0, 3], [0, 2], [0, 1]],
            [[0, 2], [1, 2], [1, 3], [1, 1], [0, 1]],
            [[0, 3], [1, 4], [0, 6], [0, 3], [0, 1]],
            [[0, 2], [1, 2], [1, 2], [0, 1], [0, 0]],
            [[0, 1], [0, 2], [0, 2], [0, 1], [0, 0]]
        ])
      end

      it 'iterates correctly twice' do
        options = { resolution: 10, width: 50, height: 50, pattern: RPENTO }
        cellmap = CellMap.new(options) 
        2.times { cellmap.next_generation }
        expect(cellmap.grid).to eq([
            [[0, 1], [0, 3], [1, 2], [0, 2], [0, 0]],
            [[0, 2], [1, 3], [1, 3], [0, 3], [0, 2]],
            [[1, 2], [0, 5], [0, 5], [1, 2], [0, 2]],
            [[0, 2], [1, 2], [1, 2], [0, 2], [0, 2]],
            [[0, 1], [0, 3], [0, 3], [0, 2], [0, 0]]
        ])
      end

      it 'iterates correcty thrice' do
        options = { resolution: 10, width: 50, height: 50, pattern: RPENTO }
        cellmap = CellMap.new(options) 
        3.times { cellmap.next_generation }
        expect(cellmap.grid).to eq([
            [[0, 3], [1, 5], [1, 6], [0, 4], [0, 1]],
            [[0, 3], [1, 4], [1, 5], [1, 3], [0, 3]],
            [[1, 2], [0, 5], [0, 6], [1, 3], [0, 3]],
            [[0, 3], [1, 4], [1, 4], [0, 3], [0, 2]],
            [[0, 3], [1, 5], [1, 5], [0, 3], [0, 0]]
        ])
      end

      it 'increments neighbours correctly' do
        options = { resolution: 10, width: 50, height: 50, pattern: RPENTO }
        cellmap = CellMap.new(options)
        cellmap.instance_eval { @next_grid = @grid }
        cellmap.send(:update_neighbours, 1, 1, 1)
        expect(cellmap.grid).to eq([
            [[0, 1], [0, 2], [0, 3], [0, 2], [0, 1]],
            [[0, 2], [0, 3], [1, 4], [1, 2], [0, 1]],
            [[0, 2], [1, 4], [1, 5], [0, 4], [0, 1]],
            [[0, 1], [0, 3], [1, 2], [0, 2], [0, 0]],
            [[0, 0], [0, 1], [0, 1], [0, 1], [0, 0]]
        ])
      end

      it 'decrements neighbours correctly' do
        options = { resolution: 10, width: 50, height: 50, pattern: RPENTO }
        cellmap = CellMap.new(options)
        cellmap.instance_eval { @next_grid = @grid }
        cellmap.send(:update_neighbours, 1, 1, -1)
        expect(cellmap.grid).to eq([
            [[0, -1], [0, 0], [0, 1], [0, 2], [0, 1]],
            [[0, 0], [0, 3], [1, 2], [1, 2], [0, 1]],
            [[0, 0], [1, 2], [1, 3], [0, 4], [0, 1]],
            [[0, 1], [0, 3], [1, 2], [0, 2], [0, 0]],
            [[0, 0], [0, 1], [0, 1], [0, 1], [0, 0]]
        ])
      end
    end


    describe 'wrapping' do
      it 'increments top left corner neighours correctly' do
        options = { resolution: 10, width: 50, height: 50, pattern: RPENTO }
        cellmap = CellMap.new(options)
        cellmap.instance_eval { @next_grid = @grid }
        cellmap.send(:update_neighbours, 0, 0, 1)
        expect(cellmap.grid).to eq([
            [[0, 0], [0, 2], [0, 2], [0, 2], [0, 2]],
            [[0, 2], [0, 4], [1, 3], [1, 2], [0, 2]],
            [[0, 1], [1, 3], [1, 4], [0, 4], [0, 1]],
            [[0, 1], [0, 3], [1, 2], [0, 2], [0, 0]],
            [[0, 1], [0, 2], [0, 1], [0, 1], [0, 1]]
        ])
      end

      it 'increments bottom left corner neighours correctly' do
        options = { resolution: 10, width: 50, height: 50, pattern: RPENTO }
        cellmap = CellMap.new(options)
        cellmap.instance_eval { @next_grid = @grid }
        cellmap.send(:update_neighbours, 0, 4, 1)
        expect(cellmap.grid).to eq([
            [[0, 1], [0, 2], [0, 2], [0, 2], [0, 2]],
            [[0, 1], [0, 3], [1, 3], [1, 2], [0, 1]],
            [[0, 1], [1, 3], [1, 4], [0, 4], [0, 1]],
            [[0, 2], [0, 4], [1, 2], [0, 2], [0, 1]],
            [[0, 0], [0, 2], [0, 1], [0, 1], [0, 1]]
        ])
      end

      it 'increments top right corner neighbours correctly' do
        options = { resolution: 10, width: 50, height: 50, pattern: RPENTO }
        cellmap = CellMap.new(options)
        cellmap.instance_eval { @next_grid = @grid }
        cellmap.send(:update_neighbours, 4, 0, 1)
        expect(cellmap.grid).to eq([
            [[0, 1], [0, 1], [0, 2], [0, 3], [0, 1]],
            [[0, 2], [0, 3], [1, 3], [1, 3], [0, 2]],
            [[0, 1], [1, 3], [1, 4], [0, 4], [0, 1]],
            [[0, 1], [0, 3], [1, 2], [0, 2], [0, 0]],
            [[0, 1], [0, 1], [0, 1], [0, 2], [0, 1]]
        ])
      end

      it 'increments bottom right corner neighbours correctly' do
        options = { resolution: 10, width: 50, height: 50, pattern: RPENTO }
        cellmap = CellMap.new(options)
        cellmap.instance_eval { @next_grid = @grid }
        cellmap.send(:update_neighbours, 4, 4, 1)
        expect(cellmap.grid).to eq([
            [[0, 1], [0, 1], [0, 2], [0, 3], [0, 2]],
            [[0, 1], [0, 3], [1, 3], [1, 2], [0, 1]],
            [[0, 1], [1, 3], [1, 4], [0, 4], [0, 1]],
            [[0, 2], [0, 3], [1, 2], [0, 3], [0, 1]],
            [[0, 1], [0, 1], [0, 1], [0, 2], [0, 0]]
        ])
      end
    end
  end
end

