import 'package:flutter/material.dart';

class ReorderableStaggeredGridViewItem<T> {
  /// The [data] is a required value for the item.
  final T? data;

  /// The [mainAxisCellCount] is the number of cells occupied by the element along the main scroll axis.
  final int mainAxisCellCount;

  /// The [crossAxisCellCount] is the number of cells occupied by the element along the cross scroll axis.
  final int crossAxisCellCount;

  /// The [child] is the widget content of the item.
  final Widget child;

  ReorderableStaggeredGridViewItem({
    required this.data,
    required this.mainAxisCellCount,
    required this.crossAxisCellCount,
    required this.child,
  });
}
