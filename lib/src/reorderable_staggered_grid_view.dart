import 'package:flutter/material.dart';
import 'package:staggered_grid_view/flutter_staggered_grid_view.dart';

import '../reorderable_staggered_grid_view.dart';

class ReorderableStaggeredGridView extends StatefulWidget {
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final List<StaggeredGridViewItem> items;
  final bool isLongPressDraggable;

  const ReorderableStaggeredGridView({
    super.key,
    required this.items,
    required this.crossAxisCount,
    required this.isLongPressDraggable,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  });

  @override
  State<ReorderableStaggeredGridView> createState() =>
      _ReorderableStaggeredGridViewState();
}

class _ReorderableStaggeredGridViewState
    extends State<ReorderableStaggeredGridView> {
  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      // UI PARAMS
      padding: EdgeInsets.all(20),
      crossAxisCount: widget.crossAxisCount,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,

      // CELL SIZE
      staggeredTileBuilder: (index) {
        final item = widget.items[index];

        return StaggeredTile.count(
          item.crossAxisCellCount,
          item.mainAxisCellCount.toDouble(),
        );
      },

      // ITEMS
      itemCount: widget.items.length,
      itemBuilder: (context, index) => DraggableGridItem(
        onAcceptWithDetails: (details) {},
        onWillAcceptWithDetails: (details) {
          return true;
        },
        isLongPressDraggable: widget.isLongPressDraggable,
        item: widget.items[index],
      ),
    );
  }
}
