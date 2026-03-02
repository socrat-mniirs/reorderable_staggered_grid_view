import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/reorder_preview_controller.dart';
import '../data/scroll_end_notifier.dart';
import '../data/reorderable_staggered_grid_view_item.dart';
import '../data/reorderable_staggered_grid_view_mode.dart';
import 'animated_grid_item_widget.dart';
import 'animated_offset.dart';

class ReorderableStaggeredGridItemWidget extends StatefulWidget {
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
  State<ReorderableStaggeredGridItemWidget> createState() =>
      _ReorderableStaggeredGridItemWidgetState();
}

class _ReorderableStaggeredGridItemWidgetState
    extends State<ReorderableStaggeredGridItemWidget> {
  late final ReorderPreviewController _reorderController;

  Offset _offset = Offset.zero;

  // 'Will accept' handler
  bool _willAcceptDelayStarted = false;
  Timer? _willAcceptDelayTimer;

  @override
  void initState() {
    super.initState();
    _reorderController = context.read<ReorderPreviewController>();
  }

  @override
  void dispose() {
    super.dispose();
    _willAcceptDelayTimer?.cancel();
  }

  /// Shifts the object, indicating that it is ready to replace another grid element
  bool _onWillAcceptWithDetails(DragTargetDetails<Object?> details) {
    if (details.data == widget.item.data) {
      return false;
    }

    switch (widget.mode) {
      // With offset animations
      case ReorderableStaggeredGridViewMode.withOffsetAnimations:
        setState(() => _offset += widget.willAcceptAnimationOffset);
        break;

      // With reorder preview
      // The animation starts after a delay when the draggable is hovered over the target
      case ReorderableStaggeredGridViewMode.withReorderPreview:
        if (!_willAcceptDelayStarted) {
          _willAcceptDelayStarted = true;
          _willAcceptDelayTimer = Timer(
            widget.onWillAcceptDuration,
            () {
              if (!mounted) return;
              _reorderController.reorderPreviewItemsOnWillAccept(
                targetIndex: widget.index,
              );
            },
          );
        }
        break;

      // Normal mode doesn't have any animation on will accept
      default:
        break;
    }

    return widget.onWillAcceptWithDetails(details);
  }

  /// Calling the passed function
  void _onAcceptWithDetails(DragTargetDetails<Object?> details) =>
      widget.onAcceptWithDetails(details);

  /// Return the target object to its original place
  void _onLeave(Object? data) {
    if (data == widget.item.data) {
      return;
    }

    switch (widget.mode) {
      // With offset animations
      case ReorderableStaggeredGridViewMode.withOffsetAnimations:
        setState(() => _offset = Offset.zero);
        break;

      // With reorder preview
      case ReorderableStaggeredGridViewMode.withReorderPreview:
        {
          // Reset 'will accept' data
          _willAcceptDelayTimer?.cancel();
          _willAcceptDelayStarted = false;

          widget.onLeave?.call(data);

          if (!mounted) return;
          _reorderController.cancelPreviousReorderChangesOnLeave();
        }
        break;

      // Normal mode
      default:
        break;
    }
  }

  /// Called when Draggable moving within DragTarget
  void _onMove(DragTargetDetails details) => widget.onMove?.call(details);

  @override
  Widget build(BuildContext context) {
    // TODO
    final child = _GridItemDraggable(
      data: widget.item.data,
      isLongPressDraggable: widget.isLongPressDraggable,

      // Dragging callbacks
      onDragStarted: widget.onDragStarted,
      onDragUpdate: widget.onDragUpdate,
      onDragEnd: widget.onDragEnd,

      // Child when dragging
      childWhenDragging: TickerMode(
        enabled: false,
        child: AnimatedGridItemWidget(
          item: null,
          key: widget.item.key,
        ),
      ),

      // Feedback
      feedback: widget.buildFeedbackWidget?.call(
            context,
            widget.item.child,
            widget.item.key,
          ) ??
          _FeedbackWidget(
            originalWidgetKey: widget.item.key,
            child: widget.item.child,
          ),

      // Child
      child: AnimatedGridItemWidget(
        item: widget.item,
        key: widget.item.key,
        isLastDraggedItem: widget.isLastDraggedItem,
      ),
    );

    return Stack(
      children: [
        // Draggable widget
        switch (widget.mode) {
          // With offset animations
          ReorderableStaggeredGridViewMode.withOffsetAnimations =>
            AnimatedOffset(
              offset: widget.willAcceptAnimationOffset,
              duration: widget.willAcceptOffsetDuration,
              child: child,
            ),

          // Other modes
          _ => child,
        },

        // Drag target (under the draggable widget)
        Positioned.fill(
          child: DragTarget(
            onMove: _onMove,
            onLeave: _onLeave,
            onWillAcceptWithDetails: _onWillAcceptWithDetails,
            onAcceptWithDetails: _onAcceptWithDetails,
            builder: (context, _, __) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

/// Widget for dragging a grid item
class _GridItemDraggable extends StatelessWidget {
  final Object? data;

  /// The [isLongPressDraggable] indicates does it take a long press to drag or not.
  final bool isLongPressDraggable;

  /// The [onDragStarted] called when the draggable starts being dragged.
  final void Function()? onDragStarted;

  /// The [onDragUpdate] called when the draggable is dragged.
  ///
  /// This function will only be called while this widget is still mounted to
  /// the tree (i.e. [State.mounted] is true), and if this widget has actually moved.
  final void Function(DragUpdateDetails details)? onDragUpdate;

  /// The [onDragEnd] called when the draggable is dropped.
  ///
  /// The velocity and offset at which the pointer was moving when it was
  /// dropped is available in the [DraggableDetails]. Also included in the
  /// `details` is whether the draggable's [DragTarget] accepted it.
  ///
  /// This function will only be called while this widget is still mounted to
  /// the tree (i.e. [State.mounted] is true).
  final void Function(DraggableDetails details)? onDragEnd;

  /// TODO doc
  final Widget childWhenDragging;
  final Widget feedback;
  final Widget child;

  const _GridItemDraggable({
    required this.data,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDragEnd,
    required this.isLongPressDraggable,
    required this.childWhenDragging,
    required this.feedback,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return isLongPressDraggable

        // Long press draggable
        ? LongPressDraggable(
            data: data,
            onDragStarted: onDragStarted,
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd,

            // Child widgets
            feedback: feedback,
            childWhenDragging: childWhenDragging,
            child: child,
          )

        // Default draggable
        : Draggable(
            data: data,
            onDragStarted: onDragStarted,
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd,

            // Child widgets
            feedback: feedback,
            childWhenDragging: childWhenDragging,
            child: child,
          );
  }
}

/// The widget which will be shown as a default dragging widget
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
