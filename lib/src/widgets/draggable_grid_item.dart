import 'package:flutter/material.dart';

import '../data/staggered_grid_view_item_data.dart';
import 'feedback_widget.dart';

class DraggableGridItem extends StatelessWidget {
  final StaggeredGridViewItem item;
  final bool isLongPressDraggable;
  final void Function(DragTargetDetails<Object?> details)? onAcceptWithDetails;
  final bool Function(DragTargetDetails<Object?> details)?
      onWillAcceptWithDetails;

  const DraggableGridItem({
    super.key,
    required this.item,
    required this.isLongPressDraggable,
    this.onAcceptWithDetails,
    this.onWillAcceptWithDetails,
  });

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();

    final draggableChild = DragTarget(
      onAcceptWithDetails: onAcceptWithDetails,
      onWillAcceptWithDetails: onWillAcceptWithDetails,
      builder: (context, candidateData, rejectedData) {
        return KeyedSubtree(
          key: key,
          child: item.child,
        );
      },
    );

    return isLongPressDraggable

        // Long press
        ? LongPressDraggable(
            data: item.data,
            feedback: FeedbackWidget(
              parentKey: key,
              child: item.child,
            ),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            childWhenDragging: const SizedBox.shrink(),
            child: draggableChild,
          )

        // Default
        : Draggable(
            data: item.data,
            feedback: FeedbackWidget(
              parentKey: key,
              child: item.child,
            ),
            childWhenDragging: const SizedBox.shrink(),
            child: draggableChild,
          );
  }
}
