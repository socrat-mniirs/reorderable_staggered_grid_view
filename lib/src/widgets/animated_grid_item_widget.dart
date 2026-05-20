import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_staggered_grid_view/src/data/reorderable_staggered_grid_mode.dart';
import 'package:reorderable_staggered_grid_view/src/widgets/animated_offset.dart';

import '../provider/reorder_preview_notifier.dart';
import '../data/reorderable_staggered_grid_item.dart';
import '../provider/scroll_end_notifier.dart';

// TODO ГДЕ-то теряется стейт некоторых итемов сетки, скорее всего где то ошибка с ключами
// Потому что не обновляется стейт -> не обновляется позиция -> виджеты отстают на шаг

// TODO earlier passed scrollEndNotifier to capture positions on scroll end, check it
// TODO make private
class AnimatedGridItemWidget extends StatefulWidget {
  final Offset? offset;
  final ReorderableStaggeredGridItem? item;
  final ReorderableStaggeredGridMode mode;
  final bool isLastDraggedItem;

  const AnimatedGridItemWidget({
    super.key,
    required this.item,
    required this.mode,
    required this.isLastDraggedItem,
    this.offset,
  });

  @override
  State<AnimatedGridItemWidget> createState() => _AnimatedGridItemWidgetState();
}

class _AnimatedGridItemWidgetState extends State<AnimatedGridItemWidget>
    with SingleTickerProviderStateMixin {
  // Animation
  late Animation<Offset> _animation;
  late AnimationController _controller;

  // Current position
  Offset _position = Offset.zero;

  // Scroll notifier
  late final ScrollEndNotifier _scrollEndNotifier;

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _controller = AnimationController(
      vsync: this,
      duration: widget.item?.duration ?? const Duration(milliseconds: 300),
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
    _scrollEndNotifier.addListener(
      () => _updatePosition(animate: false),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedGridItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // TODO sometimes blinking occurs
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updatePosition(animate: !widget.isLastDraggedItem),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollEndNotifier.removeListener(_updatePosition);
    super.dispose();
  }

  // Update current position of the item
  void _updatePosition({bool animate = true}) async {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !mounted) return;

    final oldPosition = _position;
    final newPosition = renderBox.localToGlobal(Offset.zero);
    _position = newPosition;

    // Animate from old position to a new position
    if (animate) {
      await _startAnimation(
        oldPosition: oldPosition,
        newPosition: newPosition,
      );
    }
  }

  // Animating the grid element to a new position and saving the current position after that
  Future<void> _startAnimation({
    required Offset oldPosition,
    required Offset newPosition,
  }) async {
    final delta = oldPosition - newPosition;
    if (delta == Offset.zero) return;

    _animation = Tween<Offset>(
      begin: Offset(delta.dx, delta.dy),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    await _controller.forward(from: 0);
  }

  // Preview listener
  void _previewListener() {
    final item = widget.item;
    if (item == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Find current position
    final currentPosition = renderBox.localToGlobal(Offset.zero);

    // Find target position
    final reorderPreviewNotifier = context.read<ReorderPreviewNotifier>();
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

      // TODO попроьовать обновлять позицию не в конце а во время анимации
      _controller.forward(from: 0).then((_) => _updatePosition());
    }
    // On leave
    else {
      // TODO попроьовать обновлять позицию не в конце а во время анимации
      _controller.reverse().then((_) => _updatePosition());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item == null) return const SizedBox.shrink();

    // Build UI
    final child = AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Transform.translate(
        offset: _animation.value,
        child: widget.item?.child,
      ),
    );

    return switch (widget.mode) {
      // Listen to reorder preview changes
      ReorderableStaggeredGridMode.withReorderPreview =>
        _ReorderPreviewListener(
          listener: _previewListener,
          child: child,
        ),

      // Offset animation
      ReorderableStaggeredGridMode.withOffsetAnimations =>
        // TODO убрать отсюда AnimatedOffset или придумать как не нарушить логику рендера, тк сдвигать можно ТОЛЬКО Draggable
        AnimatedOffset(
          offset: widget.offset ?? Offset.zero,
          // TODO
          duration: Durations.medium2,
          child: child,
        ),

      // Default mode
      _ => child,
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
  late final ReorderPreviewNotifier _reorderPreviewNotifier;

  @override
  void initState() {
    super.initState();
    _reorderPreviewNotifier = context.read<ReorderPreviewNotifier>();
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
