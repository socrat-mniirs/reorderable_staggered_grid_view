## 0.2.0

* BREAKING: The grid is created with ```ReorderableStaggeredGridView.builder(itemBuilder, itemCount)``` instead of the default constructor with ```items```. The grid no longer reorders items by itself, so move the dropped item in ```onAcceptWithDetails```.
* BREAKING: Rename ```ReorderableStaggeredGridViewItem``` -> ```ReorderableStaggeredGridItem```. Its ```data``` is now non-nullable, and the ```startingOffset``` parameter has been removed.
* BREAKING: ```buildFeedbackWidget``` receives the size of the original widget instead of its key.
* NEW: The ```childWhenDragging``` parameter of the grid item.
* FIX: Items blinked at their new positions before the reordering animation started.
* FIX: An external ```controller``` was disposed by the grid.
* FIX: Auto-scroll used screen coordinates instead of grid coordinates, ignored ```scrollDirection``` and ```reverse```, and could keep running after the grid was disposed.
* FIX: The ```willAcceptAnimationOffset``` was shown even if the drop was rejected.
* FIX: ```ScrollEndNotification``` no longer stops bubbling inside the grid.
* Bump Dart and Flutter versions.

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
