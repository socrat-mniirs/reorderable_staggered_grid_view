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

  // Add item
  void _addNewItem() {
    final newItem = Constants._generateItem(
      items.length,
    );
    items.add(newItem);
  }

  // Remove item
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
    final moveActionsFromAppBar = MediaQuery.of(context).size.width < 800;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // Show bottom sheet with actions
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            child: Icon(Icons.settings),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  spacing: 20,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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

                    Row(
                      spacing: 20,
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

                    // Switch enable
                    Row(
                      spacing: 20,
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

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),

        // AppBar
        appBar: AppBar(
          // Title
          title: Text('Reorderable Staggered Grid View'),

          // Actions with grid items
          actions: [
            // Switch enable
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

            if (!moveActionsFromAppBar) const SizedBox(width: 20),

            // Switch enable
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

            if (!moveActionsFromAppBar) const SizedBox(width: 20),

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
        body: LayoutBuilder(
          builder: (context, constraints) => ReorderableStaggeredGridView(
            padding: EdgeInsets.all(20),
            enable: enableDragging,
            crossAxisCount: Constants.calculateCrossAxisCount(
              constraints.maxWidth,
            ),
            mainAxisSpacing: Constants.spacing,
            crossAxisSpacing: Constants.spacing,
            isLongPressDraggable: enableLongPress,
            nonDraggableWidgetsKeys: [Constants._widgetKeys[0]!],
            items: items,
          ),
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
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black),
        ),
        child: Center(child: title),
      ),
    );
  }
}

/// An abstract class with demo data to demonstrate package possibilities.
abstract class Constants {
  static const spacing = 10.0;

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

  static ReorderableStaggeredGridViewItem _generateItem(int index) {
    final key = widgetKeyById(index);
    final animationKey = animationKeyById(index);

    int? mainAxisCellCount;
    int? crossAxisCellCount;

    return ReorderableStaggeredGridViewItem(
      animationKey: animationKey,
      data: index,
      mainAxisCellCount: mainAxisCellCount ?? Random().nextInt(2) + 1,
      crossAxisCellCount: crossAxisCellCount ?? Random().nextInt(2) + 1,
      child: TileWidget(
        key: key,
        title: Text(index == 0 ? 'Not dragged' : index.toString()),
        color: Color.fromRGBO(
          Random().nextInt(255),
          Random().nextInt(255),
          Random().nextInt(255),
          0.5,
        ),
      ),
    );
  }
}
