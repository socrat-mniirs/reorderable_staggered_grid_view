import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/src/data/reorderable_staggered_grid_view_item.dart';
import 'package:reorderable_staggered_grid_view/src/data/scroll_end_notifier.dart';
import 'package:reorderable_staggered_grid_view/src/widgets/draggable_grid_item.dart';
import 'package:reorderable_staggered_grid_view/src/widgets/animated_grid_item_widget.dart';

class ReorderableStaggeredGridItemWidget extends StatelessWidget {
  /// The [item] which can be reordered or dragged.
  final ReorderableStaggeredGridViewItem item;

  /// The [index] determines whether the position of the element in the grid has changed and whether animation needs to be started.
  final int index;

  /// The [isLastDraggedItem] using to define that
  final bool isLastDraggedItem;

  /// The [isLongPressDraggable] indicates does it take a long press to drag or not.
  final bool isLongPressDraggable;

  /// The [isDraggingEnabled] indicates is dragging enabled or not.
  final bool isDraggingEnabled;

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

  /// The [onWillAcceptWithDetails] called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  final bool Function(DragTargetDetails details) onWillAcceptWithDetails;

  /// The [onAcceptWithDetails] called when an acceptable piece of data was dropped over this drag target.
  /// It will not be called if `data` is `null`.
  final void Function(DragTargetDetails details) onAcceptWithDetails;

  /// The [buildFeedbackWidget] called when the dragging started to paint widget which will be shown as a dragging widget.
  final Widget Function(
          BuildContext context, Widget child, GlobalKey originalWidgetKey)?
      buildFeedbackWidget;

  /// The [scrollEndNotifier] notify animated grid items about end of scroll to recalculate their positions on the screen.
  final ScrollEndNotifier scrollEndNotifier;

  const ReorderableStaggeredGridItemWidget({
    super.key,
    required this.item,
    required this.isLastDraggedItem,
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
    required this.index,
    required this.onMove,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return !isDraggingEnabled

        // Not enabled dragging and drag target
        ? AnimatedGridItemWidget(
            key: item.animationKey,
            index: index,
            scrollEndNotifier: scrollEndNotifier,
            isLastDraggedItem: isLastDraggedItem,
            item: item,
          )

        // Enabled all
        : DraggableGridItem(
            // Required key to start animation
            key: ObjectKey(item),
            index: index,

            // Is long press need
            isLongPressDraggable: isLongPressDraggable,

            // Dragging + Auto-scroll
            onDragStarted: onDragStarted,
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd,
            onLeave: onLeave,
            onMove: onMove,
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
