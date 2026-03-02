import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../data/reorder_preview_notifier.dart';
import '../data/reorderable_staggered_grid_view_item.dart';

// TODO earlier passed scrollEndNotifier to capture positions on scroll end, check it

class AnimatedGridItemWidget extends StatefulWidget {
  final ReorderableStaggeredGridViewItem? item;
  final bool isLastDraggedItem;

  const AnimatedGridItemWidget({
    required super.key,
    required this.item,
    this.isLastDraggedItem = false,
  });

  @override
  State<AnimatedGridItemWidget> createState() => _AnimatedGridItemWidgetState();
}

class _AnimatedGridItemWidgetState extends State<AnimatedGridItemWidget>
    with SingleTickerProviderStateMixin {
  // Animation
  late Animation<Offset> _animation;
  late AnimationController _animationController;

  late final Duration _duration;

  // Preview reorder notifier
  late final ReorderPreviewNotifier _reorderPreviewNotifier;

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _duration = widget.item?.duration ?? const Duration(milliseconds: 300);
    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
      reverseDuration: _duration,
    );

    // Initial animation
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.item?.curve ?? Curves.easeOut,
      ),
    );

    _reorderPreviewNotifier = context.read<ReorderPreviewNotifier>();
    _reorderPreviewNotifier.addListener(_previewListener);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _reorderPreviewNotifier.removeListener(_previewListener);
  }

  void _previewListener() {
    if (widget.item == null) return;

    // Find render box
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Find current position
    final currentPosition = renderBox.localToGlobal(Offset.zero);

    // Find target position
    final positions = _reorderPreviewNotifier.positions;
    final targetPosition = positions[widget.item!.key];
    if (targetPosition == null || !mounted) return;

    // Create animation
    final delta = targetPosition - currentPosition;

    // On leave
    if (delta == Offset.zero) {
      _animationController.reverse();
      return;
    }

    // Will accept
    else {
      _animationController.stop();
      _animationController.reset();

      _animation = Tween<Offset>(
        begin: Offset.zero,
        end: delta,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: widget.item?.curve ?? Curves.easeOut,
        ),
      );

      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      // Animation
      animation: _animation,

      // Child widget
      child: widget.item!.child,

      // Animation build
      builder: (context, child) => Transform.translate(
        offset: _animation.value,
        child: child,
      ),
    );
  }
}

// class _AnimatedGridItemWidgetState extends State<AnimatedGridItemWidget>
//     with SingleTickerProviderStateMixin {
//   late final PreviewOffsetNotifier _previewOffsetNotifier;
//   late AnimationController _animationController;
//   late Animation<Offset> _animation;

//   Offset _position = Offset.zero;

//   @override
//   void initState() {
//     super.initState();

//     // Capture items positions
//     _capturePosition();

//     _previewOffsetNotifier = context.read<PreviewOffsetNotifier>();
//     _previewOffsetNotifier.addListener(_onPreviewOffsetsChanged);

//     // Capture new positions
//     widget.scrollEndNotifier.addListener(_capturePosition);

//     _animationController = AnimationController(
//       vsync: this,
//       duration: widget.item?.duration ?? const Duration(milliseconds: 300),
//     );

//     _animation = Tween<Offset>(
//       begin: _position,
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: widget.item?.curve ?? Curves.easeOut,
//       ),
//     );
//   }

//   @override
//   void didUpdateWidget(covariant AnimatedGridItemWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (_isAnimationNeeded(oldWidget)) {
//       _startAnimation();
//     } else {
//       WidgetsBinding.instance.addPostFrameCallback((_) => _capturePosition());
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _previewOffsetNotifier.removeListener(_onPreviewOffsetsChanged);
//     widget.scrollEndNotifier.removeListener(_capturePosition);
//     super.dispose();
//   }

//   bool _isAnimationNeeded(AnimatedGridItemWidget oldWidget) {
//     if (widget.isLastDraggedItem) return false;
//     if (widget.index == oldWidget.index) return false;
//     return true;
//   }

//   void _capturePosition() {
//     final renderBox = context.findRenderObject() as RenderBox?;
//     if (renderBox != null && mounted) {
//       final globalPos = renderBox.localToGlobal(
//         Offset.zero,
//         ancestor: gridRootBoxKey.currentContext?.findRenderObject(),
//       );
//       _position = globalPos;
//     }
//   }

//   void _onPreviewOffsetsChanged() {
//     if (widget.item == null) return;

//     final positions = _previewOffsetNotifier.positions;
//     final targetPos = positions[widget.item!.animationKey];

//     if (targetPos == null || !mounted) return;

//     final renderBox = context.findRenderObject() as RenderBox?;
//     if (renderBox == null) return;
//     _capturePosition();

//     _animationController.stop();
//     _animationController.reset();

//     final delta = targetPos - _position;
//     print(delta);

//     _animation = Tween<Offset>(
//       begin: Offset.zero,
//       end: delta,
//     ).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: widget.item?.curve ?? Curves.easeOut,
//       ),
//     );

//     _animationController.forward().then((_) => _capturePosition());
//   }

//   void _startAnimation() {
//     final renderBox = context.findRenderObject() as RenderBox?;
//     if (renderBox == null || !mounted) return;

//     final currentPos = renderBox.localToGlobal(
//       Offset.zero,
//       ancestor: gridRootBoxKey.currentContext?.findRenderObject(),
//     );

//     _animationController.stop();
//     _animationController.reset();

//     _animation = Tween<Offset>(
//       begin: currentPos - _position,
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: widget.item?.curve ?? Curves.easeOut,
//       ),
//     );

//     _animationController.forward().then((_) => _capturePosition());
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.item == null) return const SizedBox.shrink();

//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) => Transform.translate(
//         offset: _animation.value,
//         child: child,
//       ),
//       child: widget.item!.child,
//     );
//   }
// }
