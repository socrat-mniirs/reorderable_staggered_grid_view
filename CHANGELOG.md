## 0.1.1

* FIX: Fixed the error of dynamically changing crossAxisCount by changing the grid key (the scenario is a bypass of the well-known bug in the StaggeredGridView package, in which the positions of elements are incorrectly recalculated or not redrawn).

## 0.1.0+1

* Format dart code

## 0.1.0

* NEW: Add two callbacks - ```onMove()``` and ```onLeave()```
* NEW: Rename ```offsetWhenAppear``` -> ```startingOffset``` and make it open in the initialization constructor of ```ReorderableStaggeredGridViewItem```.
* FIX: Do not recalculating coordinates when a new offset animation starts before the forst animation completed
* FIX: Optimize repaintings when dragging has ended, but the order of the elemets has not changed

## 0.0.1+1

* Fix the generation of grid elements in the example.

## 0.0.1

* Initial release.
