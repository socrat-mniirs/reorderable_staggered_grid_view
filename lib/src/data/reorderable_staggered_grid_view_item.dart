import 'package:flutter/material.dart';

class ReorderableStaggeredGridViewItem {
  /// The [key] is a required unique identifier for the item.
  final Key key;

  /// The [mainAxisCellCount] is the number of cells occupied by the element along the main scroll axis.
  final int mainAxisCellCount;

  /// The [crossAxisCellCount] is the number of cells occupied by the element along the cross scroll axis.
  final int crossAxisCellCount;

  /// The [child] is the widget content of the item.
  final Widget child;

  ReorderableStaggeredGridViewItem({
    required this.key,
    required this.mainAxisCellCount,
    required this.crossAxisCellCount,
    required this.child,
  });
}
