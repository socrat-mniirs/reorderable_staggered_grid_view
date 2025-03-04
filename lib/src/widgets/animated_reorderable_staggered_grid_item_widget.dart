import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/src/data/reorderable_staggered_grid_view_item.dart';
import 'package:reorderable_staggered_grid_view/src/widgets/draggable_grid_item.dart';

class AnimatedReorderableStaggeredGridItemWidget extends StatefulWidget {
  final ReorderableStaggeredGridViewItem item;

  final ReorderableStaggeredGridViewItem? lastDraggedItem;

  final ReorderableStaggeredGridViewItem? draggingItem;

  final bool isLongPressDraggable;

  final Duration duration;

  final Duration reverseDuration;

  final Duration offsetDuration;

  final Offset animationOffset;

  final void Function() resetLastDraggedItem;

  final void Function(DragUpdateDetails details) onDragUpdate;

  final void Function(DraggableDetails details) onDragEnd;

  final bool Function(DragTargetDetails details) onWillAcceptWithDetails;

  final void Function(DragTargetDetails details) onAcceptWithDetails;

  final Widget Function(
          BuildContext context, Widget child, GlobalKey originalWidgetKey)?
      buildFeedbackWidget;

  const AnimatedReorderableStaggeredGridItemWidget({
    super.key,
    required this.item,
    required this.lastDraggedItem,
    required this.draggingItem,
    required this.resetLastDraggedItem,
    required this.isLongPressDraggable,
    required this.duration,
    required this.reverseDuration,
    required this.offsetDuration,
    required this.animationOffset,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onWillAcceptWithDetails,
    required this.onAcceptWithDetails,
    required this.buildFeedbackWidget,
  });

  @override
  State<AnimatedReorderableStaggeredGridItemWidget> createState() =>
      _AnimatedReorderableStaggeredGridItemWidgetState();
}

class _AnimatedReorderableStaggeredGridItemWidgetState
    extends State<AnimatedReorderableStaggeredGridItemWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      // Duration
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,

      // Animation
      transitionBuilder: (child, animation) {
        if (
            // Cancel unnecessary repaints when first
            widget.lastDraggedItem != null
                // Check if objects are equal
                &&
                widget.item.key == widget.lastDraggedItem?.key
                // Check animation duplicates
                &&
                animation.status == AnimationStatus.dismissed) {
          // lastDraggedItem = null;
          widget.resetLastDraggedItem();
          return widget.draggingItem != null ? const SizedBox.shrink() : child;
        }

        final mainAxisOffsetCoef = 1 / widget.item.mainAxisCellCount;
        final crossAxisOffsetCoef = 1 / widget.item.crossAxisCellCount;

        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(
              0 * crossAxisOffsetCoef,
              1 * mainAxisOffsetCoef,
            ),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },

      // Child
      child: DraggableGridItem(
        // Required key to start animation
        key: ObjectKey(widget.item),

        // Is long press need
        isLongPressDraggable: widget.isLongPressDraggable,

        // Dragging + Auto-scroll
        onDragUpdate: widget.onDragUpdate,
        onDragEnd: widget.onDragEnd,

        // Offset when dragging over
        animationOffset: widget.animationOffset,
        offsetDuration: widget.offsetDuration,

        // Will accept
        onWillAcceptWithDetails: widget.onWillAcceptWithDetails,

        // Accept
        onAcceptWithDetails: widget.onAcceptWithDetails,

        // Feedback widget
        buildFeedbackWidget: widget.buildFeedbackWidget,

        // Child
        item: widget.item,
      ),
    );
  }
}
