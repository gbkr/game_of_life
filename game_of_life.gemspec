Gem::Specification.new do |s|
  s.name = 'Game of Life'
  s.version = '0.0.1'
  s.authors = ["Greg Baker"]
  s.date = %q{2013-05-22}
  s.description = 'Simple Game of Life implementation'
  s.summary = s.description
  s.email = 'gba311 at gmail.com'
  s.files = %w{
    bin/game_of_life
    lib/game_of_life.rb
    lib/game_of_life/window.rb
    lib/game_of_life/grid_base.rb
    lib/game_of_life/grid_builder.rb
    lib/game_of_life/cell_map.rb
  }
  s.require_paths = ['lib', 'lib/game_of_life']
  s.has_rdoc = false
  s.bindir = 'bin'
  s.executables = ['game_of_life']
  s.add_development_dependency('gosu')
  s.add_runtime_dependency('gosu')
end
