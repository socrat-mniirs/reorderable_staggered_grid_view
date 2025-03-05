import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/src/data/reorderable_staggered_grid_view_item.dart';
import 'package:reorderable_staggered_grid_view/src/widgets/draggable_grid_item.dart';

class AnimatedReorderableStaggeredGridItemWidget extends StatefulWidget {
  final ReorderableStaggeredGridViewItem item;

  final ReorderableStaggeredGridViewItem? lastDraggedItem;

  final ReorderableStaggeredGridViewItem? draggingItem;

  final bool isLongPressDraggable;

  final bool isDraggingEnabled;

  final Duration slidableAnimationDuration;

  final Offset slidableAnimationOffset;

  final Duration willAcceptOffsetDuration;

  final Offset willAcceptAnimationOffset;

  final void Function() resetLastDraggedItem;

  final void Function(DragUpdateDetails details) onDragUpdate;

  final void Function(DraggableDetails details) onDragEnd;

  final bool Function(DragTargetDetails details) onWillAcceptWithDetails;

  final void Function(DragTargetDetails details) onAcceptWithDetails;

  final Widget Function(
          BuildContext context, Widget child, GlobalKey originalWidgetKey)?
      buildFeedbackWidget;

  const AnimatedReorderableStaggeredGridItemWidget({
    super.key,
    required this.item,
    required this.lastDraggedItem,
    required this.draggingItem,
    required this.resetLastDraggedItem,
    required this.isDraggingEnabled,
    required this.isLongPressDraggable,
    required this.slidableAnimationDuration,
    required this.slidableAnimationOffset,
    required this.willAcceptOffsetDuration,
    required this.willAcceptAnimationOffset,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onWillAcceptWithDetails,
    required this.onAcceptWithDetails,
    required this.buildFeedbackWidget,
  });

  @override
  State<AnimatedReorderableStaggeredGridItemWidget> createState() =>
      _AnimatedReorderableStaggeredGridItemWidgetState();
}

class _AnimatedReorderableStaggeredGridItemWidgetState
    extends State<AnimatedReorderableStaggeredGridItemWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.slidableAnimationDuration,
    );

    final crossAxisOffsetCoef = 1 / widget.item.crossAxisCellCount;
    final mainAxisOffsetCoef = 1 / widget.item.mainAxisCellCount;

    _animation = Tween<Offset>(
      begin: Offset(
        widget.slidableAnimationOffset.dx * crossAxisOffsetCoef,
        widget.slidableAnimationOffset.dy * mainAxisOffsetCoef,
      ),
      end: Offset.zero,
    ).animate(_controller);

    _controller.forward(from: widget.isDraggingEnabled ? 0 : 1);

    super.initState();
  }

  @override
  void didUpdateWidget(
    covariant AnimatedReorderableStaggeredGridItemWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.item.key != oldWidget.item.key) {
      if (widget.item.key != widget.lastDraggedItem?.key) {
        _controller.forward(from: 0);
      } else {
        widget.resetLastDraggedItem();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,

      // Builder with animated slide
      builder: (context, child) => SlideTransition(
        position: _animation,
        child: child,
      ),

      // Child
      child: !widget.isDraggingEnabled

          // Not enabled dragging, darg target, animations
          ? widget.item.child

          // Enabled all
          : DraggableGridItem(
              // Required key to start animation
              key: ObjectKey(widget.item),

              // Is long press need
              isLongPressDraggable: widget.isLongPressDraggable,

              // Dragging + Auto-scroll
              onDragUpdate: widget.onDragUpdate,
              onDragEnd: widget.onDragEnd,

              // Offset when dragging over
              animationOffset: widget.willAcceptAnimationOffset,
              offsetDuration: widget.willAcceptOffsetDuration,

              // Will accept
              onWillAcceptWithDetails: widget.onWillAcceptWithDetails,

              // Accept
              onAcceptWithDetails: widget.onAcceptWithDetails,

              // Feedback widget
              buildFeedbackWidget: widget.buildFeedbackWidget,

              // Child
              item: widget.item,
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
