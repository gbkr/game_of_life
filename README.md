Game of Life
============

An implementation of the cellular automaton, [Game of Life](http://en.wikipedia.org/wiki/Conways_Game_of_Life), devised by John Conway.


Why is this interesting?
------------------------

In the two-dimensional universe of Life there is only a simple set of laws operating to determine the state of the system. From this simplicity, patterns begin to emerge. These processes are deterministic; once an initial configuration is chosen, it is only the laws which determine what happens in each successive generation.

Early patterns may morph and die, form stable configurations, begin to oscillate, or evolve into more complex shapes. An interesting pattern at this scale is the glider. Note that no rules for movement exist, yet gliders fly. No rules for collision exist either, but gliders will collide with any object on their path spawning a whole new set of evolving patterns.

Beyond oscillators and gliders, more and more complex shapes begin to emerge. For each level of scale an entire physics can be devised. The mathematician, John von Neumann has estimated that a self-replicating pattern could even be created and estimates a minimum size for this object at ten trillion cells (approximately the number of molecules in a human cell).

Gliders can be used to represent bit streams (the presence of a glider being a 1 and the absence a 0). Various patterns can be used to process these streams, thereby ensuring the computation of boolean and basic logic functions (AND/OR/NOT).

The game can be used to implement both a [Universal Turing machine](http://www.igblan.free-online.co.uk/igblan/ca/) and a [Von Neumann Universal Constructor](http://conwaylife.com/wiki/Universal_constructor).

All this from just 2 simple rules.


Installation
------------

The Gosu library needs to be installed. Instructions can be found on the [Gosu wiki](https://github.com/gosu/gosu/wiki).

Complete the installation with `bundle && rake install`


Usage
-----

Starting the program without any options will present a blank grid. Cells can be drawn using the left mouse button and the game started with either the right mouse button or by pressing the enter key.

For options, run `game_of_life -h`

Example starting configurations are included as LIF files in the examples directory.
eg. `game_of_life -r4 -p examples/C3PUF.LIF`
