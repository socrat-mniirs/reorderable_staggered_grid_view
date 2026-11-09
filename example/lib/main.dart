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
  late final List<ReorderableStaggeredGridItem> _items;

  // Grid configuration
  bool _enableDragging = true;
  bool _enableLongPress = false;

  UniqueKey? _gridKey;
  int? _lastCrossAxisCount;

  @override
  void initState() {
    super.initState();

    // Generate items
    _items = List<ReorderableStaggeredGridItem>.generate(50, _generateItem);
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
  ReorderableStaggeredGridItem _generateItem(int index) {
    // Make the first item non-draggable
    final isDraggable = index != 0;

    return ReorderableStaggeredGridItem(
      // Data
      data: index,
      isDraggable: isDraggable,

      // Grid size
      mainAxisCellCount: Random().nextInt(2) + 1,
      crossAxisCellCount: Random().nextInt(2) + 1,

      // Child
      child: _ItemWidget(
        // Personal recommendation: to save the child's internal state, specify the global key
        key: GlobalKey(),
        index: index,
        isDraggable: isDraggable,
      ),
    );
  }

  // Calculate crossAxisCount by maxWidth
  int _calculateCrossAxisCount(double maxWidth) {
    if (maxWidth < 500) {
      return 6;
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
    final isPhoneScreen = !(MediaQuery.of(context).size.width > 800);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // AppBar
        appBar: AppBar(
          // Title
          title: Text('Reorderable Staggered Grid View'),

          // Actions with grid items
          actions: [
            if (!isPhoneScreen) ...[
              // Long press
              _LongPressConfig(
                enableLongPress: _enableLongPress,
                onChanged: (value) => setState(
                  () => _enableLongPress = value,
                ),
              ),
              const SizedBox(width: 10),

              // Enable/Disable dragging config
              _DraggingConfig(
                enable: _enableDragging,
                onChanged: (value) => setState(
                  () => _enableDragging = value,
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

            return ReorderableStaggeredGridView.builder(
              key: _gridKey,

              // Config
              padding: EdgeInsets.all(5),
              enable: _enableDragging,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              // Phones always use long press, otherwise dragging conflicts with scrolling
              isLongPressDraggable: isPhoneScreen || _enableLongPress,
              willAcceptAnimationOffset: Offset(15, 15),

              // Items & reordering
              itemCount: _items.length,
              itemBuilder: (_, index) => _items[index],
              onAcceptWithDetails: (details, newIndex) {
                final draggingItem = _items.firstWhere(
                  (e) => e.data == details.data,
                );
                final draggingIndex = _items.indexOf(draggingItem);

                _items.removeAt(draggingIndex);
                _items.insert(newIndex, draggingItem);

                setState(() {});
              },
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
  final bool isDraggable;
  final Color color;

  _ItemWidget({
    super.key,
    required this.index,
    required this.isDraggable,
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
          isDraggable ? index.toString() : 'Not dragged',
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
