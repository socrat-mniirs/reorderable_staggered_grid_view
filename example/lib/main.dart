import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/reorderable_staggered_grid_view.dart';

import 'item_widget.dart';
import 'settings_sheet.dart';

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
  late GridSettings _settings;

  @override
  void initState() {
    super.initState();

    final isMobile = switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.android => true,
      _ => false,
    };

    _settings = GridSettings(
      enableDragging: true,
      // On mobile, dragging without long press conflicts with scrolling
      enableLongPress: isMobile,
      crossAxisCount: isMobile ? 4 : 8,
    );

    // Generate items
    _items = List<ReorderableStaggeredGridItem>.generate(
      101,
      _generateItem,
    );
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
      child: ItemWidget(
        // Personal recommendation: to save the child's internal state, specify the global key
        key: GlobalKey(),
        index: index,
        isDraggable: isDraggable,
      ),
    );
  }

  // Add new item to the end of the list
  void _addNewItem() => setState(
        () => _items.add(_generateItem(_items.length)),
      );

  // Remove item from the end of the list
  void _removeItem() => setState(() {
        if (_items.isNotEmpty) _items.removeLast();
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // AppBar
        appBar: AppBar(
          title: Text('Reorderable Staggered Grid View'),
        ),

        // Settings
        floatingActionButton: Builder(
          // Context below MaterialApp is needed to show the bottom sheet
          builder: (context) => FloatingActionButton(
            tooltip: 'Settings',
            onPressed: () => showSettingsSheet(
              context,
              settings: _settings,
              onChanged: (value) => setState(() => _settings = value),
              onAddItem: _addNewItem,
              onRemoveItem: _removeItem,
            ),
            child: const Icon(Icons.settings),
          ),
        ),

        // Body
        body: ReorderableStaggeredGridView.builder(
          // Config
          padding: EdgeInsets.all(5),
          enable: _settings.enableDragging,
          crossAxisCount: _settings.crossAxisCount,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          isLongPressDraggable: _settings.enableLongPress,
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
        ),
      ),
    );
  }
}
