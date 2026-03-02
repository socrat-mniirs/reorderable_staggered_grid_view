import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/reorderable_staggered_grid_view.dart';

void main() {
  runApp(const ReorderableStaggeredGridViewExample());
}

class ReorderableStaggeredGridViewExample extends StatefulWidget {
  const ReorderableStaggeredGridViewExample({super.key});

  @override
  State<ReorderableStaggeredGridViewExample> createState() =>
      _ReorderableStaggeredGridViewExampleState();
}

class _ReorderableStaggeredGridViewExampleState
    extends State<ReorderableStaggeredGridViewExample> {
  List<ReorderableStaggeredGridViewItem> items = List.from(
    ExampleData.reorderableStaggeredGridViewItems,
  );

  bool enableLongPress = false;
  bool enableDragging = true;

  UniqueKey? _gridKey;
  int? _lastCrossAxisCount;

  // Add item
  void _addNewItem() {
    final newItem = ExampleData._generateItem(
      items.length,
    );
    items.add(newItem);
  }

  // Remove item
  void _removeItem() {
    if (items.isNotEmpty) {
      // Necessary to avoid keys duplicates
      final removedIndex =
          ExampleData.reorderableStaggeredGridViewItems.indexOf(
        items.last,
      );
      ExampleData._animationKeys.remove(removedIndex);

      items.removeLast();
    }
  }

  @override
  Widget build(BuildContext context) {
    final moveActionsFromAppBar = MediaQuery.of(context).size.width < 800;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // AppBar
        appBar: AppBar(
          // Title
          title: Text('Reorderable Staggered Grid View'),

          // Actions with grid items
          actions: [
            // Long press
            if (!moveActionsFromAppBar)
              Row(
                children: [
                  Text(
                    'Long press ${enableLongPress ? 'enabled' : 'disabled'}',
                  ),
                  Switch(
                    value: enableLongPress,
                    onChanged: (value) => setState(
                      () => enableLongPress = value,
                    ),
                  ),
                ],
              ),

            if (!moveActionsFromAppBar) const SizedBox(width: 10),

            // Enable / disable dragging
            if (!moveActionsFromAppBar)
              Row(
                children: [
                  Text(
                    'Dragging ${enableDragging ? 'enabled' : 'disabled'}',
                  ),
                  Switch(
                    value: enableDragging,
                    onChanged: (value) => setState(
                      () => enableDragging = value,
                    ),
                  ),
                ],
              ),

            if (!moveActionsFromAppBar) const SizedBox(width: 10),

            // Remove last
            Tooltip(
              message: 'Remove last item',
              child: IconButton(
                onPressed: () => setState(_removeItem),
                icon: Icon(Icons.clear),
              ),
            ),

            // Add new
            Tooltip(
              message: 'Add new item',
              child: IconButton(
                onPressed: () => setState(_addNewItem),
                icon: Icon(Icons.add),
              ),
            ),

            const SizedBox(width: 15),
          ],
        ),

        // Show bottom sheet with actions
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            child: Icon(Icons.settings),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  spacing: 10,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close bottom sheet
                    Center(
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Container(
                          width: 50,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    // Long press
                    Row(
                      spacing: 10,
                      children: [
                        Text(
                          'Long press ${enableLongPress ? 'enabled' : 'disabled'}',
                        ),
                        Switch(
                          value: enableLongPress,
                          onChanged: (value) => setState(
                            () => enableLongPress = value,
                          ),
                        ),
                      ],
                    ),

                    // Enable / disable dragging
                    Row(
                      spacing: 10,
                      children: [
                        Text(
                          'Dragging ${enableDragging ? 'enabled' : 'disabled'}',
                        ),
                        Switch(
                          value: enableDragging,
                          onChanged: (value) => setState(
                            () => enableDragging = value,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Body
        body: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = ExampleData.calculateCrossAxisCount(
              constraints.maxWidth,
            );

            if (_lastCrossAxisCount != crossAxisCount) {
              _lastCrossAxisCount = crossAxisCount;
              _gridKey = UniqueKey();
            }

            return ReorderableStaggeredGridView.withReorderPreview(
              key: _gridKey,
              padding: EdgeInsets.all(10),
              enable: enableDragging,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              isLongPressDraggable: enableLongPress,
              onWillAcceptDuration: Durations.long2,
              items: items,
            );
          },
        ),
      ),
    );
  }
}

/// The class with example data to demonstrate package possibilities.
class ExampleData {
  /// Calculate crossAxisCount by maxWidth
  static int calculateCrossAxisCount(double maxWidth) {
    if (maxWidth < 500) {
      return 2;
    } else if (maxWidth < 1000) {
      return 4;
    } else if (maxWidth < 1500) {
      return 6;
    } else {
      return 8;
    }
  }

  /// Widget's keys
  static final Map<int, GlobalKey> _widgetKeys = {};
  static GlobalKey widgetKeyById(int id) => _widgetKeys.putIfAbsent(
        id,
        () => GlobalKey(),
      );

  /// Animation widget's keys
  static final Map<int, GlobalKey> _animationKeys = {};
  static GlobalKey animationKeyById(int id) => _animationKeys.putIfAbsent(
        id,
        () => GlobalKey(),
      );

  /// Items
  static final List<ReorderableStaggeredGridViewItem>
      reorderableStaggeredGridViewItems = List.generate(
    100,
    _generateItem,
  );

  /// Generate [ReorderableStaggeredGridViewItem]
  static ReorderableStaggeredGridViewItem _generateItem(int index) {
    final key = widgetKeyById(index);

    int? mainAxisCellCount;
    int? crossAxisCellCount;

    return ReorderableStaggeredGridViewItem(
      data: index,
      mainAxisCellCount: mainAxisCellCount ?? Random().nextInt(2) + 1,
      crossAxisCellCount: crossAxisCellCount ?? Random().nextInt(2) + 1,
      isDraggable: index != 0, // Make the first item not draggable

      // Tile widget
      child: DecoratedBox(
        key: key,
        decoration: BoxDecoration(
          color: Color.fromRGBO(
            Random().nextInt(255),
            Random().nextInt(255),
            Random().nextInt(255),
            0.5,
          ),
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Text(
            index == 0 ? 'Not dragged' : index.toString(),
          ),
        ),
      ),
    );
  }
}
