import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/src/data/reorderable_staggered_grid_view_item.dart';
import 'package:reorderable_staggered_grid_view/src/data/scroll_end_notifier.dart';
import 'package:reorderable_staggered_grid_view/src/widgets/draggable_grid_item.dart';
import 'package:reorderable_staggered_grid_view/src/widgets/animated_grid_item_widget.dart';

class ReorderableStaggeredGridItemWidget extends StatelessWidget {
  final ReorderableStaggeredGridViewItem item;

  final ReorderableStaggeredGridViewItem? lastDraggedItem;

  final ReorderableStaggeredGridViewItem? draggingItem;

  final bool isLongPressDraggable;

  final bool isDraggingEnabled;

  final Duration slidableAnimationDuration;

  final Offset slidableAnimationOffset;

  final Duration willAcceptOffsetDuration;

  final Offset willAcceptAnimationOffset;

  final void Function() resetLastDraggedItem;

  final void Function(DragUpdateDetails details) onDragUpdate;

  final void Function(DraggableDetails details) onDragEnd;

  final bool Function(DragTargetDetails details) onWillAcceptWithDetails;

  final void Function(DragTargetDetails details) onAcceptWithDetails;

  final Widget Function(
          BuildContext context, Widget child, GlobalKey originalWidgetKey)?
      buildFeedbackWidget;

  final ScrollEndNotifier scrollEndNotifier;

  const ReorderableStaggeredGridItemWidget({
    super.key,
    required this.item,
    required this.lastDraggedItem,
    required this.draggingItem,
    required this.resetLastDraggedItem,
    required this.isDraggingEnabled,
    required this.isLongPressDraggable,
    required this.slidableAnimationDuration,
    required this.slidableAnimationOffset,
    required this.willAcceptOffsetDuration,
    required this.willAcceptAnimationOffset,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onWillAcceptWithDetails,
    required this.onAcceptWithDetails,
    required this.buildFeedbackWidget,
    required this.scrollEndNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return !isDraggingEnabled

        // Not enabled dragging, drag target, animations
        ? AnimatedGridItemWidget(
            key: item.animationKey,
            scrollEndNotifier: scrollEndNotifier,
            item: item,
          )

        // Enabled all
        : DraggableGridItem(
            // Required key to start animation
            key: ObjectKey(item),

            // Is long press need
            isLongPressDraggable: isLongPressDraggable,

            // Dragging + Auto-scroll
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd,
            scrollEndNotifier: scrollEndNotifier,

            // Offset when dragging over
            animationOffset: willAcceptAnimationOffset,
            offsetDuration: willAcceptOffsetDuration,

            // Will accept
            onWillAcceptWithDetails: onWillAcceptWithDetails,

            // Accept
            onAcceptWithDetails: onAcceptWithDetails,

            // Feedback widget
            buildFeedbackWidget: buildFeedbackWidget,

            // Child
            item: item,
          );
  }
}
