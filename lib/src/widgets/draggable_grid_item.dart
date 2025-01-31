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

  DraggableGridItem({
    super.key,
    required this.item,
    this.isLongPressDraggable = false,
    this.onDragUpdate,
    this.onDragEnd,
    this.onAcceptWithDetails,
    this.onWillAcceptWithDetails,
  });

  final parentKey = GlobalKey();

  @override
  State<DraggableGridItem> createState() => _DraggableGridItemState();
}

class _DraggableGridItemState extends State<DraggableGridItem> {
  Offset offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final dragTargetWidget = DragTargetGridItem(
      key: widget.parentKey,
      item: widget.item,
      onAcceptWithDetails: (details) {
        widget.onAcceptWithDetails?.call(details);
      },
      onLeave: (data) {
        if (data == widget.item.data) {
          return;
        }

        setState(() {
          offset -= Offset(50, 50);
        });
      },
      onWillAcceptWithDetails: (details) {
        if (details.data == widget.item.data) {
          return false;
        }

        setState(() {
          offset += Offset(50, 50);
        });

        return widget.onWillAcceptWithDetails?.call(details) ?? true;
      },
    );

    return AnimatedOffset(
      duration: Duration(milliseconds: 200),
      offset: offset,
      child: widget.isLongPressDraggable

          // Long press
          ? LongPressDraggable(
              onDragUpdate: widget.onDragUpdate,
              onDragEnd: widget.onDragEnd,
              data: widget.item.data,
              feedback: FeedbackWidget(
                parentKey: widget.parentKey,
                child: widget.item.child,
              ),
              dragAnchorStrategy: pointerDragAnchorStrategy,
              childWhenDragging: const SizedBox.shrink(),
              child: dragTargetWidget,
            )

          // Default
          : Draggable(
              onDragUpdate: widget.onDragUpdate,
              onDragEnd: widget.onDragEnd,
              data: widget.item.data,
              feedback: FeedbackWidget(
                parentKey: widget.parentKey,
                child: widget.item.child,
              ),
              childWhenDragging: const SizedBox.shrink(),
              child: dragTargetWidget,
            ),
    );
  }
}
