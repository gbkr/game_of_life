module GameOfLife
  class GridBase

    attr_reader :grid, :height, :width, :resolution, :wrap, :pattern, :rules, :freq

    def initialize(options)
      @width = options.fetch(:width, 800)
      @height = options.fetch(:height, 800)
      @resolution = options.fetch(:resolution, 10)
      @wrap = options.fetch(:wrap, true)
      @pattern = options[:pattern]
      @rules = life_rules options.fetch(:rules, '23/3')
      @freq = frequency options[:frame_rate]
    end

    def rows
      height / resolution
    end

    def columns
      width / resolution
    end

    private

    Rules = Struct.new(:survival, :birth)
    def life_rules(rule)
      rule.strip!
      rule = rule.sub('#R ', '').split('/') if rule =~ /#R/
      rules = rule.split('/').map {|e| e.split(//).map {|n| n.to_i } }
      Rules.new(rules[0], rules[1])
    end

    def frequency rate
      1 / rate.to_f if rate
    end
  end
end
