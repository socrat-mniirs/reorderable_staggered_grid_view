import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/reorder_preview_controller.dart';
import '../data/scroll_end_notifier.dart';
import '../data/reorderable_staggered_grid_view_item.dart';
import '../data/reorderable_staggered_grid_view_mode.dart';
import 'animated_grid_item_widget.dart';
import 'draggable_target.dart';

part 'grid_item_draggable.dart';
part 'grid_item_drag_target.dart';

class ReorderableStaggeredGridItemWidget extends StatelessWidget {
  /// The [item] which can be reordered or dragged.
  final ReorderableStaggeredGridViewItem item;

  /// The [mode] of the reorderable staggered grid view.
  final ReorderableStaggeredGridViewMode mode;

  /// The [index] determines whether the position of the element in the grid has changed and whether animation needs to be started.
  final int index;

  /// The [isLastDraggedItem] using to define that
  final bool isLastDraggedItem;

  /// The [isLongPressDraggable] indicates does it take a long press to drag or not.
  final bool isLongPressDraggable;

  /// The [isDraggingEnabled] indicates is dragging enabled or not.
  final bool isDraggingEnabled;

  /// The [onWillAcceptDuration] is the delay before the animation which indicates that the rebuild will be accepted.
  final Duration onWillAcceptDuration;

  /// The [willAcceptOffsetDuration] is an animation duration of [willAcceptAnimationOffset].
  final Duration willAcceptOffsetDuration;

  /// The [willAcceptAnimationOffset] is an animation offset on [onWillAcceptWithDetails].
  final Offset willAcceptAnimationOffset;

  /// The [onDragStarted] called when the draggable starts being dragged.
  final void Function() onDragStarted;

  /// The [onDragUpdate] called when the draggable is dragged.
  ///
  /// This function will only be called while this widget is still mounted to
  /// the tree (i.e. [State.mounted] is true), and if this widget has actually moved.
  final void Function(DragUpdateDetails details) onDragUpdate;

  /// The [onDragEnd] called when the draggable is dropped.
  ///
  /// The velocity and offset at which the pointer was moving when it was
  /// dropped is available in the [DraggableDetails]. Also included in the
  /// `details` is whether the draggable's [DragTarget] accepted it.
  ///
  /// This function will only be called while this widget is still mounted to
  /// the tree (i.e. [State.mounted] is true).
  final void Function(DraggableDetails details) onDragEnd;

  /// The [onMove] called when draggable moving within drag target.
  final void Function(DragTargetDetails details)? onMove;

  /// The [onLeave] called when a given piece of data being dragged over this target leaves
  /// the target.
  final void Function(Object? data)? onLeave;

  /// The [onAcceptWithDetails] called when an acceptable piece of data was dropped over this drag target.
  /// It will not be called if `data` is `null`.
  final void Function(DragTargetDetails details) onAcceptWithDetails;

  /// The [onWillAcceptWithDetails] called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  final bool Function(DragTargetDetails details) onWillAcceptWithDetails;

  /// The [buildFeedbackWidget] called when the dragging started to paint widget which will be shown as a dragging widget.
  final Widget Function(
          BuildContext context, Widget child, GlobalKey originalWidgetKey)?
      buildFeedbackWidget;

  /// The [scrollEndNotifier] notify animated grid items about end of scroll to recalculate their positions on the screen.
  final ScrollEndNotifier scrollEndNotifier;

  const ReorderableStaggeredGridItemWidget({
    super.key,
    required this.item,
    required this.mode,
    required this.isLastDraggedItem,
    required this.isDraggingEnabled,
    required this.isLongPressDraggable,
    required this.willAcceptOffsetDuration,
    required this.willAcceptAnimationOffset,
    required this.onWillAcceptDuration,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onWillAcceptWithDetails,
    required this.onAcceptWithDetails,
    required this.buildFeedbackWidget,
    required this.scrollEndNotifier,
    required this.index,
    required this.onMove,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return !isDraggingEnabled

        // Not enabled dragging and drag target
        ? AnimatedGridItemWidget(
            item: item,
            key: item.animationKey,
            isLastDraggedItem: isLastDraggedItem,
          )

        // Enabled all
        : DraggableTarget(
            // Required key to start animation
            key: ObjectKey(item),

            // Grid mode
            mode: mode,

            // Item
            item: item,
            index: index,

            // Dragging + Auto-scroll
            onMove: onMove,
            onLeave: onLeave,

            // Offset when dragging over
            offsetDuration: willAcceptOffsetDuration,
            animationOffset: willAcceptAnimationOffset,
            onWillAcceptDuration: onWillAcceptDuration,

            // Will accept
            onWillAcceptWithDetails: onWillAcceptWithDetails,

            // Accept
            onAcceptWithDetails: onAcceptWithDetails,

            // Feedback widget
            buildFeedbackWidget: buildFeedbackWidget,

            // Draggable
            draggable: _GridItemDraggable(
              data: item.data,
              isLongPressDraggable: isLongPressDraggable,

              // Dragging callbacks
              onDragStarted: onDragStarted,
              onDragUpdate: onDragUpdate,
              onDragEnd: onDragEnd,

              // Child when dragging
              childWhenDragging: TickerMode(
                enabled: false,
                child: AnimatedGridItemWidget(
                  item: null,
                  key: item.animationKey,
                ),
              ),

              // Feedback
              feedback: buildFeedbackWidget?.call(
                    context,
                    item.child,
                    // TODO is this need?
                    item.animationKey,
                  ) ??
                  _FeedbackWidget(
                    originalWidgetKey: item.animationKey,
                    child: item.child,
                  ),

              // Child
              child: AnimatedGridItemWidget(
                item: item,
                key: item.animationKey,
                isLastDraggedItem: isLastDraggedItem,
              ),
            ),
          );
  }
}

/// Feedback widget
class _FeedbackWidget extends StatelessWidget {
  final GlobalKey originalWidgetKey;

  final Widget child;

  const _FeedbackWidget({
    required this.child,
    required this.originalWidgetKey,
  });

  @override
  Widget build(BuildContext context) {
    // Default build
    assert(originalWidgetKey.currentContext != null);

    // Get initial sizes of the grid item widget
    final itemWidget =
        originalWidgetKey.currentContext?.findRenderObject() as RenderBox;
    final size = itemWidget.size;

    return Material(
      elevation: 15,
      shadowColor: Colors.black,
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: child,
      ),
    );
  }
}
