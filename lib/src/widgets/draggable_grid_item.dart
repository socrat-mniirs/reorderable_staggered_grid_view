import 'package:flutter/material.dart';

import '../data/staggered_grid_view_item.dart';
import 'animated_offset.dart';
import 'drag_target_grid_item.dart';
import 'feedback_widget.dart';

class DraggableGridItem extends StatefulWidget {
  final StaggeredGridViewItem item;

  final bool isLongPressDraggable;

  final void Function(DragUpdateDetails details)? onDragUpdate;

  final void Function(DraggableDetails details)? onDragEnd;

  final void Function(DragTargetDetails<Object?> details)? onAcceptWithDetails;

  final bool Function(DragTargetDetails<Object?> details)?
      onWillAcceptWithDetails;

  final parentKey = GlobalKey();

  DraggableGridItem({
    super.key,
    required this.item,
    this.isLongPressDraggable = false,
    this.onDragUpdate,
    this.onDragEnd,
    this.onAcceptWithDetails,
    this.onWillAcceptWithDetails,
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

    setState(() {
      offset -= Offset(50, 50);
    });
  }

  /// [_onWillAcceptWithDetails] - shifts the object, indicating that it is ready to replace another grid element
  ///
  bool _onWillAcceptWithDetails(DragTargetDetails<Object?> details) {
    if (details.data == widget.item.key) {
      return false;
    }

    setState(() {
      offset += Offset(50, 50);
    });

    return widget.onWillAcceptWithDetails?.call(details) ?? true;
  }

  /// [_onAcceptWithDetails] - calling the passed function
  ///
  void _onAcceptWithDetails(DragTargetDetails<Object?> details) =>
      widget.onAcceptWithDetails?.call(details);

  @override
  Widget build(BuildContext context) {
    return AnimatedOffset(
      duration: Duration(milliseconds: 200),
      offset: offset,
      child: widget.isLongPressDraggable

          // Long press
          ? LongPressDraggable(
              data: widget.item.key,
              onDragUpdate: widget.onDragUpdate,
              onDragEnd: widget.onDragEnd,
              dragAnchorStrategy: pointerDragAnchorStrategy,
              childWhenDragging: const SizedBox.shrink(),
              feedback: FeedbackWidget(
                parentKey: widget.parentKey,
                child: widget.item.child,
              ),

              // Child
              child: DragTargetGridItem(
                key: widget.parentKey,
                item: widget.item,
                onLeave: _onLeave,
                onWillAcceptWithDetails: _onWillAcceptWithDetails,
                onAcceptWithDetails: _onAcceptWithDetails,
              ),
            )

          // Default
          : Draggable(
              data: widget.item.key,
              onDragUpdate: widget.onDragUpdate,
              onDragEnd: widget.onDragEnd,
              childWhenDragging: const SizedBox.shrink(),
              feedback: FeedbackWidget(
                parentKey: widget.parentKey,
                child: widget.item.child,
              ),

              // Child
              child: DragTargetGridItem(
                key: widget.parentKey,
                item: widget.item,
                onLeave: _onLeave,
                onWillAcceptWithDetails: _onWillAcceptWithDetails,
                onAcceptWithDetails: _onAcceptWithDetails,
              ),
            ),
    );
  }
}
