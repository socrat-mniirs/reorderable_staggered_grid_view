import 'package:flutter/material.dart';

class ReorderableStaggeredGridViewItem<T> {
  /// The [data] is a required value for the item.
  final T? data;

  /// The [animationKey] is a required unique identifier for the animation during dragging.
  final GlobalKey animationKey;

  /// The [mainAxisCellCount] is the number of cells occupied by the element along the main scroll axis.
  final int mainAxisCellCount;

  /// The [crossAxisCellCount] is the number of cells occupied by the element along the cross scroll axis.
  final int crossAxisCellCount;

  /// The [duration] is the time duration of the item's animation when dragging accepted.
  final Duration duration;

  /// The [curve] is a parametric animation easing curve, i.e. a mapping of the unit interval to the unit interval.
  final Curve curve;

  /// The [offsetWhenAppear] is the widget's animation offset when the widget's content firstly has been built.
  final Offset offsetWhenAppear;

  /// The [child] is the widget content of the item.
  final Widget child;

  ReorderableStaggeredGridViewItem({
    required this.data,
    required this.animationKey,
    required this.mainAxisCellCount,
    required this.crossAxisCellCount,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    required this.child,
  }) : offsetWhenAppear = Offset(
          1 / crossAxisCellCount,
          (1 / mainAxisCellCount) * 100,
        );
}
