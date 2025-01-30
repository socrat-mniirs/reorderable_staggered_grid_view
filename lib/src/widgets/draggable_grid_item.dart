import 'package:flutter/material.dart';

import '../data/staggered_grid_view_item_data.dart';

class DraggableGridItem extends StatelessWidget {
  final StaggeredGridViewItem item;
  final void Function(DragTargetDetails<Object?> details)? onAcceptWithDetails;
  final bool Function(DragTargetDetails<Object?> details)?
      onWillAcceptWithDetails;

  const DraggableGridItem({
    super.key,
    required this.item,
    this.onAcceptWithDetails,
    this.onWillAcceptWithDetails,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      onAcceptWithDetails: onAcceptWithDetails,
      onWillAcceptWithDetails: onWillAcceptWithDetails,
      builder: (context, candidateData, rejectedData) {
        final mainAxisSlidingCoef = 1 / item.mainAxisCellCount;
        final crossAxisSlidingCoef = 1 / item.crossAxisCellCount;

        return AnimatedSlide(
          duration: Duration(
            milliseconds: candidateData.isEmpty ? 200 : 1000,
          ),
          offset: Offset(
            candidateData.isEmpty ? 0 : 2 * crossAxisSlidingCoef,
            candidateData.isEmpty ? 0 : 2 * mainAxisSlidingCoef,
          ),
          child: item.child,
        );
      },
    );
  }
}
