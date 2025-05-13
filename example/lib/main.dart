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
    Constants.reorderableStaggeredGridViewItems,
  );

  bool enableLongPress = false;
  bool enableDragging = true;

  void _addNewItem() {
    final newItem = Constants._generateItem(
      items.length,
    );
    items.add(newItem);
  }

  void _removeItem() {
    if (items.isNotEmpty) {
      // Necessary to avoid keys duplicates
      final removedIndex = Constants.reorderableStaggeredGridViewItems.indexOf(
        items.last,
      );
      Constants._animationKeys.remove(removedIndex);

      items.removeLast();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // AppBar
        appBar: AppBar(
          // Title
          title: Text('Reorderable Staggered Grid View'),

          // Actions with grid items
          actions: [
            // Switch enable
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

            const SizedBox(width: 20),

            // Switch enable
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

            const SizedBox(width: 20),

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

            const SizedBox(width: 20),
          ],
        ),

        // Body
        body: ReorderableStaggeredGridView(
          padding: EdgeInsets.all(20),
          enable: enableDragging,
          crossAxisCount: Constants.crossAxisCount,
          mainAxisSpacing: Constants.spacing,
          crossAxisSpacing: Constants.spacing,
          isLongPressDraggable: enableLongPress,
          nonDraggableWidgetsKeys: [Constants._widgetKeys[0]!],
          items: items,
        ),
      ),
    );
  }
}

/// A widget content of a grid item which using to demonstrate the package possibilities.
class TileWidget extends StatelessWidget {
  final Widget title;
  final Color color;

  const TileWidget({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black),
      ),
      child: Center(child: title),
    );
  }
}

/// An abstract class with demo data to demonstrate package possibilities.
abstract class Constants {
  static const crossAxisCount = 8;
  static const spacing = 10.0;

  // Widget's keys
  static final Map<int, GlobalKey> _widgetKeys = {};
  static GlobalKey widgetKeyById(int id) => _widgetKeys.putIfAbsent(
        id,
        () => GlobalKey(),
      );

  // Animation widget's keys
  static final Map<int, GlobalKey> _animationKeys = {};
  static GlobalKey animationKeyById(int id) => _animationKeys.putIfAbsent(
        id,
        () => GlobalKey(),
      );

  // Items
  static final List<ReorderableStaggeredGridViewItem>
      reorderableStaggeredGridViewItems = List.generate(
    100,
    _generateItem,
  );

  static ReorderableStaggeredGridViewItem _generateItem(dynamic id) {
    final key = widgetKeyById(id);
    final animationKey = animationKeyById(id);

    return ReorderableStaggeredGridViewItem(
      animationKey: animationKey,
      data: id,
      mainAxisCellCount: Random().nextInt(2) + 1,
      crossAxisCellCount: Random().nextInt(2) + 1,
      child: TileWidget(
        key: key,
        title: Text(id == 0 ? 'Not dragged' : id.toString()),
        color: Color.from(
          alpha: 0.1,
          red: Random().nextInt(255).toDouble(),
          green: Random().nextInt(255).toDouble(),
          blue: Random().nextInt(255).toDouble(),
        ),
      ),
    );
  }
}
