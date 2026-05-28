import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_staggered_grid_view/src/data/reorderable_staggered_grid_mode.dart';
import 'package:reorderable_staggered_grid_view/src/widgets/animated_offset.dart';

import '../provider/preview_positions_controller.dart';
import '../data/reorderable_staggered_grid_item.dart';
import '../provider/scroll_end_notifier.dart';

class AnimatedGridItemWidget extends StatefulWidget {
  final Offset? offset;
  final Duration? duration;
  final ReorderableStaggeredGridItem? item;
  final ReorderableStaggeredGridMode mode;
  final bool isLastDraggedItem;
  final Widget child;

  AnimatedGridItemWidget({
    required super.key,
    required ReorderableStaggeredGridItem this.item,
    required this.mode,
    required this.isLastDraggedItem,
    required this.offset,
    required this.duration,
  }) : child = item.child;

  const AnimatedGridItemWidget.customChild({
    required super.key,
    required this.isLastDraggedItem,
    required this.mode,
    required this.child,
  }) : item = null,
       offset = null,
       duration = null;

  @override
  State<AnimatedGridItemWidget> createState() => _AnimatedGridItemWidgetState();
}

class _AnimatedGridItemWidgetState extends State<AnimatedGridItemWidget>
    with SingleTickerProviderStateMixin {
  // Animation
  late Animation<Offset> _animation;
  late AnimationController _controller;

  // Current position relative to widget itself
  Offset _position = Offset.zero;
  Offset _oldPosition = Offset.zero;

  // Delta
  Offset get _delta => _oldPosition - _position;

  // Scroll notifier
  late final ScrollEndNotifier _scrollEndNotifier;

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _controller = AnimationController(
      vsync: this,
      duration: widget.item?.duration ?? Durations.medium2,
    );

    // Initial animation
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.item?.curve ?? Curves.easeOut,
      ),
    );

    // Initially capture positions
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePosition());

    // Listen to scroll end to capture positions after scrolling
    _scrollEndNotifier = context.read<ScrollEndNotifier>();
    _scrollEndNotifier.addListener(_updatePosition);
  }

  @override
  void didUpdateWidget(covariant AnimatedGridItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // TODO Sometimes blinking occurs
    // After changing state capture positions and animate reordering
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _updatePosition();
        if (!widget.isLastDraggedItem) _animateReordering();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollEndNotifier.removeListener(_updatePosition);
    super.dispose();
  }

  // Update current position of the item
  void _updatePosition({bool animate = false}) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !mounted) return;

    // Capture a new couple of positions
    _oldPosition = _position;
    _position = renderBox.localToGlobal(Offset.zero);
  }

  // Animating element to a new position in the grid
  void _animateReordering() {
    _animation = Tween<Offset>(
      begin: _delta,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward(from: 0);
  }

  // Preview listener
  // TODO Вызывается второй раз из-за PreviewGrid после onAccept, хотя логика под это не подходит. Нужно задоджить логику функции при onAccept. Вызов происходит в консумере в PreviewGrid
  void _previewListener() async {
    final item = widget.item;
    if (item == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final currentPosition = renderBox.localToGlobal(Offset.zero);
    _position = currentPosition;

    // Find target position
    final reorderPreviewNotifier = context.read<PreviewPositionsController>();
    final targetPosition = reorderPreviewNotifier.positions[item.key];
    if (targetPosition == null || !mounted) return;

    // Create animation
    final delta = targetPosition - currentPosition;

    // On will accept
    if (delta != Offset.zero) {
      _controller.stop();
      _controller.reset();

      _animation = Tween<Offset>(
        begin: Offset.zero,
        end: delta,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: item.curve,
        ),
      );

      _controller.forward(from: 0).then((_) => _updatePosition());
    }
    // On leave
    else {
      _controller.reverse().then((_) => _updatePosition());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build UI
    final child = AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder:
          (_, child) => Transform.translate(
            offset: _animation.value,
            child: child,
          ),
    );

    return switch (widget.mode) {
      // Listen to reorder preview changes
      ReorderableStaggeredGridMode.buildWithReorderPreview =>
        _ReorderPreviewListener(
          listener: _previewListener,
          child: child,
        ),

      // Offset animation
      ReorderableStaggeredGridMode.builder => AnimatedOffset(
        offset: widget.offset ?? Offset.zero,
        duration: widget.duration ?? Durations.medium2,
        child: child,
      ),
    };
  }
}

/// Listen to reorder preview changes
class _ReorderPreviewListener extends StatefulWidget {
  final VoidCallback listener;
  final Widget child;

  const _ReorderPreviewListener({
    required this.listener,
    required this.child,
  });

  @override
  State<_ReorderPreviewListener> createState() =>
      _ReorderPreviewListenerState();
}

class _ReorderPreviewListenerState extends State<_ReorderPreviewListener> {
  late final PreviewPositionsController _reorderPreviewNotifier;

  @override
  void initState() {
    super.initState();
    _reorderPreviewNotifier = context.read<PreviewPositionsController>();
    _reorderPreviewNotifier.addListener(widget.listener);
  }

  @override
  void dispose() {
    _reorderPreviewNotifier.removeListener(widget.listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
