import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/src/data/reorderable_staggered_grid_view_item.dart';
import 'package:reorderable_staggered_grid_view/src/data/scroll_end_notifier.dart';
import 'package:reorderable_staggered_grid_view/src/widgets/draggable_grid_item.dart';
import 'package:reorderable_staggered_grid_view/src/widgets/animated_grid_item_widget.dart';

class ReorderableStaggeredGridItemWidget extends StatelessWidget {
  /// The [item] which can be reordered or dragged.
  final ReorderableStaggeredGridViewItem item;

  /// The [isLastDraggedItem] using to define that
  final bool isLastDraggedItem;

  final ReorderableStaggeredGridViewItem? draggingItem;

  final bool isLongPressDraggable;

  final bool isDraggingEnabled;

  final Duration willAcceptOffsetDuration;

  final Offset willAcceptAnimationOffset;

  final void Function() resetLastDraggedItem;

  final void Function() onDragStarted;

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
    required this.isLastDraggedItem,
    required this.draggingItem,
    required this.resetLastDraggedItem,
    required this.isDraggingEnabled,
    required this.isLongPressDraggable,
    required this.willAcceptOffsetDuration,
    required this.willAcceptAnimationOffset,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onWillAcceptWithDetails,
    required this.onAcceptWithDetails,
    required this.buildFeedbackWidget,
    required this.scrollEndNotifier,
  });

  @override
  Widget build(BuildContext context) {
    if (identical(item, draggingItem)) {
      return const SizedBox.shrink();
    }

    return !isDraggingEnabled

        // Not enabled dragging and drag target
        ? AnimatedGridItemWidget(
            key: item.animationKey,
            scrollEndNotifier: scrollEndNotifier,
            isLastDraggedItem: isLastDraggedItem,
            item: item,
          )

        // Enabled all
        : DraggableGridItem(
            // Required key to start animation
            key: ObjectKey(item),

            // Is long press need
            isLongPressDraggable: isLongPressDraggable,

            // Dragging + Auto-scroll
            onDragStarted: onDragStarted,
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
            isLastDraggedItem: isLastDraggedItem,
            item: item,
          );
  }
}
