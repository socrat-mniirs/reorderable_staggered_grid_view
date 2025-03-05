import 'package:flutter/material.dart';

import '../data/reorderable_staggered_grid_view_item.dart';
import 'animated_offset.dart';
import 'drag_target_grid_item.dart';

class DraggableGridItem extends StatefulWidget {
  final ReorderableStaggeredGridViewItem item;

  final bool isLongPressDraggable;

  final void Function()? onDragStarted;

  final void Function(DragUpdateDetails details)? onDragUpdate;

  final void Function(DraggableDetails details)? onDragEnd;

  final void Function(DragTargetDetails<Object?> details)? onAcceptWithDetails;

  final bool Function(DragTargetDetails<Object?> details)?
      onWillAcceptWithDetails;

  /// The animation offset on [onWillAcceptWithDetails]
  final Offset animationOffset;

  /// The [animationOffset] animation duration
  final Duration offsetDuration;

  final Widget Function(
          BuildContext context, Widget child, GlobalKey originalWidgetKey)?
      buildFeedbackWidget;

  final originalWidgetKey = GlobalKey();

  DraggableGridItem({
    super.key,
    required this.item,
    this.isLongPressDraggable = false,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDragEnd,
    this.onAcceptWithDetails,
    this.onWillAcceptWithDetails,
    this.animationOffset = const Offset(50, 50),
    this.offsetDuration = const Duration(milliseconds: 200),
    this.buildFeedbackWidget,
  });

  @override
  State<DraggableGridItem> createState() => _DraggableGridItemState();
}

class _DraggableGridItemState extends State<DraggableGridItem> {
  Offset offset = Offset.zero;

  /// [_onLeave] - return the target object to its original place
  ///
  void _onLeave(Object? data) {
    if (data == widget.item.key) {
      return;
    }

    setState(() => offset -= widget.animationOffset);
  }

  /// [_onWillAcceptWithDetails] - shifts the object, indicating that it is ready to replace another grid element
  ///
  bool _onWillAcceptWithDetails(DragTargetDetails<Object?> details) {
    if (details.data == widget.item.key) {
      return false;
    }

    setState(() => offset += widget.animationOffset);

    return widget.onWillAcceptWithDetails?.call(details) ?? true;
  }

  /// [_onAcceptWithDetails] - calling the passed function
  ///
  void _onAcceptWithDetails(DragTargetDetails<Object?> details) =>
      widget.onAcceptWithDetails?.call(details);

  @override
  Widget build(BuildContext context) {
    return AnimatedOffset(
      duration: widget.offsetDuration,
      offset: offset,
      child: widget.isLongPressDraggable

          // ===== LONG PRESS =====

          ? LongPressDraggable(
              data: widget.item.key,
              onDragStarted: widget.onDragStarted,
              onDragUpdate: widget.onDragUpdate,
              onDragEnd: widget.onDragEnd,
              dragAnchorStrategy: pointerDragAnchorStrategy,
              childWhenDragging: const SizedBox.shrink(),
              feedback: _FeedbackWidget(
                buildFeedbackWidget: widget.buildFeedbackWidget,
                originalWidgetKey: widget.originalWidgetKey,
                child: widget.item.child,
              ),

              // Child
              child: DragTargetGridItem(
                key: widget.originalWidgetKey,
                item: widget.item,
                onLeave: _onLeave,
                onWillAcceptWithDetails: _onWillAcceptWithDetails,
                onAcceptWithDetails: _onAcceptWithDetails,
              ),
            )

          // ===== DEFAULT PRESS =====

          : Draggable(
              data: widget.item.key,
              onDragStarted: widget.onDragStarted,
              onDragUpdate: widget.onDragUpdate,
              onDragEnd: widget.onDragEnd,
              childWhenDragging: const SizedBox.shrink(),
              feedback: _FeedbackWidget(
                buildFeedbackWidget: widget.buildFeedbackWidget,
                originalWidgetKey: widget.originalWidgetKey,
                child: widget.item.child,
              ),

              // Child
              child: DragTargetGridItem(
                key: widget.originalWidgetKey,
                item: widget.item,
                onLeave: _onLeave,
                onWillAcceptWithDetails: _onWillAcceptWithDetails,
                onAcceptWithDetails: _onAcceptWithDetails,
              ),
            ),
    );
  }
}

/// Feedback widget
class _FeedbackWidget extends StatelessWidget {
  final GlobalKey originalWidgetKey;

  final Widget Function(
    BuildContext context,
    Widget child,
    GlobalKey originalWidgetKey,
  )? buildFeedbackWidget;

  final Widget child;

  const _FeedbackWidget({
    required this.buildFeedbackWidget,
    required this.child,
    required this.originalWidgetKey,
  });

  @override
  Widget build(BuildContext context) {
    /// ===== CUSTOM BUILD =====
    ///
    if (buildFeedbackWidget != null) {
      return buildFeedbackWidget!(
        context,
        child,
        originalWidgetKey,
      );
    }

    /// ===== DEFAULT BUILD =====
    ///
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
