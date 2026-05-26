import 'package:flutter/material.dart';

class ReorderableStaggeredGridItem<T extends Object> {
  /// The [data] is a required value for the item.
  final T data;

  /// The [key] is a required unique identifier for the animation during dragging.
  final GlobalKey key;

  /// The [isDraggable] determines whether the item can be dragged.
  final bool isDraggable;

  /// The [mainAxisCellCount] is the number of cells occupied by the element along the main scroll axis.
  final int mainAxisCellCount;

  /// The [crossAxisCellCount] is the number of cells occupied by the element along the cross scroll axis.
  final int crossAxisCellCount;

  /// The [duration] is the time duration of the item's animation when dragging accepted.
  final Duration duration;

  /// The [curve] is a parametric animation easing curve, i.e. a mapping of the unit interval to the unit interval.
  final Curve curve;

  /// A widget that is displayed instead of the original child while it is being dragged.
  /// Note: [childWhenDragging] is ignored when the grid mode is [ReorderableStaggeredGridMode.buildWithReorderPreview].
  final Widget? childWhenDragging;

  /// The [child] is the widget content of the item.
  final Widget child;

  /// The [ReorderableStaggeredGridItem] is an object which describe its [child] constraints and behavior
  /// in grid view.
  ReorderableStaggeredGridItem({
    GlobalKey? key,
    required this.data,
    required this.mainAxisCellCount,
    required this.crossAxisCellCount,
    required this.child,
    this.childWhenDragging,
    this.isDraggable = true,
    this.duration = Durations.medium2,
    this.curve = Curves.easeOut,
  }) : key = key ?? GlobalKey(),

       // Use different keys to avoid duplication
       assert(
         childWhenDragging?.key != child.key && childWhenDragging?.key != key,
       );
}
