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
  // Items
  late final List<ReorderableStaggeredGridViewItem> _items;

  // Configurations
  bool enableDragging = true;
  bool enableLongPress = false;

  UniqueKey? _gridKey;
  int? _lastCrossAxisCount;

  @override
  void initState() {
    super.initState();

    // Generate items
    _items = List<ReorderableStaggeredGridViewItem>.generate(
      20,
      _generateItem,
    );
  }

  // Add new item to the end of the list
  void _addNewItem() => _items.add(_generateItem(_items.length));

  // Remove item from the end of the list
  void _removeItem() {
    if (_items.isNotEmpty) {
      _items.removeLast();
    }
  }

  // Generate item
  ReorderableStaggeredGridViewItem _generateItem(int index) =>
      ReorderableStaggeredGridViewItem(
        // Data
        data: index,
        isDraggable: index != 0, // Make the first item not draggable

        // Grid size
        mainAxisCellCount: Random().nextInt(2) + 1,
        crossAxisCellCount: Random().nextInt(2) + 1,

        // Widget
        child: _ItemWidget(
          // Assign a global key to save the internal state
          key: GlobalKey(),
          index: index,
        ),
      );

  // Calculate crossAxisCount by maxWidth
  int _calculateCrossAxisCount(double maxWidth) {
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

  @override
  Widget build(BuildContext context) {
    final actionsInAppBar = MediaQuery.of(context).size.width > 800;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // AppBar
        appBar: AppBar(
          // Title
          title: Text('Reorderable Staggered Grid View'),

          // Actions with grid items
          actions: [
            if (actionsInAppBar) ...[
              // Long press
              _LongPressConfig(
                enableLongPress: enableLongPress,
                onChanged: (value) => setState(
                  () => enableLongPress = value,
                ),
              ),

              const SizedBox(width: 10),

              // Enable/Disable dragging config

              _DraggingConfig(
                enable: enableDragging,
                onChanged: (value) => setState(
                  () => enableDragging = value,
                ),
              ),

              const SizedBox(width: 10),
            ],

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

        // Body
        body: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _calculateCrossAxisCount(
              constraints.maxWidth,
            );

            if (_lastCrossAxisCount != crossAxisCount) {
              _lastCrossAxisCount = crossAxisCount;
              _gridKey = UniqueKey();
            }

            // Use [.withReorderPreview] named constructor to preview reorder operations
            return ReorderableStaggeredGridView.withReorderPreview(
              key: _gridKey,
              padding: EdgeInsets.all(10),
              enable: enableDragging,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              isLongPressDraggable: enableLongPress,
              onWillAcceptDuration: Durations.long2,
              items: _items,
            );
          },
        ),
      ),
    );
  }
}

// Item widget
class _ItemWidget extends StatelessWidget {
  final int index;
  final Color color;

  _ItemWidget({
    super.key,
    required this.index,
  }) : color = Color.fromRGBO(
          Random().nextInt(255),
          Random().nextInt(255),
          Random().nextInt(255),
          0.5,
        );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: Text(
          index == 0 ? 'Not dragged' : index.toString(),
        ),
      ),
    );
  }
}

// Long press config
class _LongPressConfig extends StatelessWidget {
  final bool enableLongPress;
  final void Function(bool) onChanged;

  const _LongPressConfig({
    required this.enableLongPress,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Long press ${enableLongPress ? 'enabled' : 'disabled'}',
        ),
        Switch(
          value: enableLongPress,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// Dragging config
class _DraggingConfig extends StatelessWidget {
  final bool enable;
  final void Function(bool) onChanged;

  const _DraggingConfig({
    required this.enable,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Dragging ${enable ? 'enabled' : 'disabled'}',
        ),
        Switch(
          value: enable,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
