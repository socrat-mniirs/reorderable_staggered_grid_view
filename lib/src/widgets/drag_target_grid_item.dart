import 'package:flutter/material.dart';

import '../data/staggered_grid_view_item.dart';

class DragTargetGridItem extends StatelessWidget {
  ///
  final StaggeredGridViewItem item;

  ///
  final void Function(DragTargetDetails<Object?> details)? onAcceptWithDetails;

  ///
  final bool Function(DragTargetDetails<Object?> details)?
      onWillAcceptWithDetails;

  /// 
  final void Function(Object? data)? onLeave;

  const DragTargetGridItem({
    super.key,
    required this.item,
    this.onAcceptWithDetails,
    this.onWillAcceptWithDetails, this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      onAcceptWithDetails: onAcceptWithDetails,
      onWillAcceptWithDetails: onWillAcceptWithDetails,
      onLeave: onLeave,
      builder: (context, candidateData, _) => item.child,
    );
  }
}
