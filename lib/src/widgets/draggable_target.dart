import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/reorder_preview_controller.dart';
import '../data/reorderable_staggered_grid_view_item.dart';
import '../data/reorderable_staggered_grid_view_mode.dart';
import 'animated_offset.dart';

class DraggableTarget extends StatefulWidget {
  /// The [item] is a grid widget that can be reordered or dragged.
  final ReorderableStaggeredGridViewItem item;

  /// The [mode] of the reorderable staggered grid view.
  final ReorderableStaggeredGridViewMode mode;

  /// The [index] determines whether the position of the element in the grid has changed and whether animation needs to be started.
  final int index;

  /// The [onMove] called when draggable moving within drag target.
  final void Function(DragTargetDetails details)? onMove;

  /// The [onLeave] called when a given piece of data being dragged over this target leaves
  /// the target.
  final void Function(Object? data)? onLeave;

  /// The [onAcceptWithDetails] called when an acceptable piece of data was dropped over this drag target.
  /// It will not be called if `data` is `null`.
  final void Function(DragTargetDetails<Object?> details)? onAcceptWithDetails;

  /// The [onWillAcceptWithDetails] called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  final bool Function(DragTargetDetails<Object?> details)?
      onWillAcceptWithDetails;

  /// The [onWillAcceptDuration] is the delay before the animation which indicates that the rebuild will be accepted.
  final Duration onWillAcceptDuration;

  /// The animation offset on [onWillAcceptWithDetails].
  final Offset animationOffset;

  /// The [offsetDuration] is an animation duration of [animationOffset].
  final Duration offsetDuration;

  /// The [buildFeedbackWidget] called when the dragging started to paint widget which will be shown as a dragging widget.
  final Widget Function(
          BuildContext context, Widget child, GlobalKey originalWidgetKey)?
      buildFeedbackWidget;

  // TODO commend
  final Widget draggable;

  const DraggableTarget({
    super.key,
    required this.item,
    required this.mode,
    required this.onMove,
    required this.onLeave,
    required this.onAcceptWithDetails,
    required this.onWillAcceptWithDetails,
    required this.onWillAcceptDuration,
    required this.animationOffset,
    required this.offsetDuration,
    required this.buildFeedbackWidget,
    required this.index,
    required this.draggable,
  });

  @override
  State<DraggableTarget> createState() => _DraggableTargetState();
}

class _DraggableTargetState extends State<DraggableTarget> {
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

    // Start animation timer
    if (!_willAcceptDelayStarted) {
      _willAcceptDelayStarted = true;

      _willAcceptDelayTimer = Timer(
        widget.onWillAcceptDuration,
        () {
          if (!mounted) return;

          _reorderController.reorderPreviewItemsOnWillAccept(
            targetIndex: widget.index,
          );
          // setState(() {
          //   offset += widget.animationOffset;
          // });
        },
      );
    }

    return widget.onWillAcceptWithDetails?.call(details) ?? false;
  }

  /// Calling the passed function
  void _onAcceptWithDetails(DragTargetDetails<Object?> details) =>
      widget.onAcceptWithDetails?.call(details);

  /// Return the target object to its original place
  void _onLeave(Object? data) {
    if (data == widget.item.data) {
      return;
    }

    // Reset 'will accept' data
    _willAcceptDelayTimer?.cancel();
    _willAcceptDelayStarted = false;

    widget.onLeave?.call(data);

    if (!mounted) return;

    _reorderController.cancelPreviousReorderChangesOnLeave();
    // setState(
    //   () => offset = Offset.zero,
    // );
  }

  /// Called when Draggable moving within DragTarget
  void _onMove(DragTargetDetails details) => widget.onMove?.call(details);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated draggable widget (above drag target)
        AnimatedOffset(
          offset: _offset,
          duration: widget.offsetDuration,
          child: widget.draggable,
        ),

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
