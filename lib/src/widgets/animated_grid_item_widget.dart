import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../data/reorderable_staggered_grid_item.dart';
import '../data/reorderable_staggered_grid_mode.dart';
import '../provider/preview_positions_controller.dart';
import 'animated_offset.dart';

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
    with TickerProviderStateMixin {
  // Animation of moving the item from its previous position in the grid to the new one
  late final AnimationController _reorderController;
  late CurvedAnimation _reorderAnimation;

  // Animation of the reorder preview
  late final AnimationController _previewController;
  late Animation<Offset> _previewAnimation;

  late final GridItemsPositions _gridItemsPositions;

  Duration get _duration => widget.item?.duration ?? Durations.medium2;
  Curve get _curve => widget.item?.curve ?? Curves.easeOut;

  @override
  void initState() {
    super.initState();

    _gridItemsPositions = context.read<GridItemsPositions>();

    _reorderController = AnimationController(
      vsync: this,
      duration: _duration,
      value: 1,
    );
    _reorderAnimation = CurvedAnimation(
      parent: _reorderController,
      curve: _curve,
    );

    _previewController = AnimationController(vsync: this, duration: _duration);
    _previewAnimation = const AlwaysStoppedAnimation(Offset.zero);
  }

  @override
  void didUpdateWidget(covariant AnimatedGridItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Apply new animation settings
    _reorderController.duration = _duration;
    _previewController.duration = _duration;
    if (_reorderAnimation.curve != _curve) {
      _reorderAnimation.dispose();
      _reorderAnimation = CurvedAnimation(
        parent: _reorderController,
        curve: _curve,
      );
    }
  }

  @override
  void dispose() {
    _reorderAnimation.dispose();
    _reorderController.dispose();
    _previewController.dispose();
    super.dispose();
  }

  // Preview listener
  // TODO Вызывается второй раз из-за PreviewGrid после onAccept, хотя логика под это не подходит. Нужно задоджить логику функции при onAccept. Вызов происходит в консумере в PreviewGrid
  void _previewListener() {
    final item = widget.item;
    if (item == null || !mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final currentPosition = renderBox.localToGlobal(Offset.zero);

    // Find target position
    final previewPositionsController =
        context.read<PreviewPositionsController>();
    final targetPosition = previewPositionsController.positions[item.key];
    if (targetPosition == null) return;

    final delta = targetPosition - currentPosition;

    // On will accept
    if (delta != Offset.zero) {
      _previewAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: delta,
      ).animate(CurvedAnimation(parent: _previewController, curve: item.curve));

      _previewController.forward(from: 0);
    }
    // On leave
    else {
      _previewController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = switch (widget.mode) {
      // Listen to reorder preview changes
      ReorderableStaggeredGridMode.buildWithReorderPreview =>
        _ReorderPreviewListener(
          listener: _previewListener,
          child: AnimatedBuilder(
            animation: _previewController,
            child: widget.child,
            builder:
                (_, child) => Transform.translate(
                  offset: _previewAnimation.value,
                  child: child,
                ),
          ),
        ),

      // Offset animation
      ReorderableStaggeredGridMode.builder => AnimatedOffset(
        offset: widget.offset ?? Offset.zero,
        duration: widget.duration ?? Durations.medium2,
        child: widget.child,
      ),
    };

    return _ReorderTransition(
      positions: _gridItemsPositions,
      animation: _reorderAnimation,
      onStart: () => _reorderController.forward(from: 0),
      // The last dragged item is not animated, because it is dropped right into its new place
      isEnabled: !widget.isLastDraggedItem,
      child: child,
    );
  }
}

/// Captures positions of all grid items on the screen before the grid is rebuilt.
///
/// The positions must be captured before rebuilding, because while rebuilding the items
/// can be moved to other places of the widget tree (by their global keys).
/// After the new layout every item compares its new position with the captured one while painting,
/// so it is painted at the old place in the first frame and doesn't blink before the animation starts.
class GridItemsPositions {
  final Set<_RenderReorderTransition> _items = {};

  void capture() {
    for (final item in _items) {
      item.captureCurrentPosition();
    }
  }
}

/// Paints the child shifted from its previous position in the grid to the current one.
class _ReorderTransition extends SingleChildRenderObjectWidget {
  final GridItemsPositions positions;
  final Animation<double> animation;
  final VoidCallback onStart;
  final bool isEnabled;

  const _ReorderTransition({
    required this.positions,
    required this.animation,
    required this.onStart,
    required this.isEnabled,
    required super.child,
  });

  @override
  _RenderReorderTransition createRenderObject(BuildContext context) =>
      _RenderReorderTransition(
        positions: positions,
        animation: animation,
        onStart: onStart,
        isEnabled: isEnabled,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderReorderTransition renderObject,
  ) {
    renderObject
      ..animation = animation
      ..onStart = onStart
      ..isEnabled = isEnabled;
  }
}

class _RenderReorderTransition extends RenderProxyBox {
  _RenderReorderTransition({
    required this.positions,
    required Animation<double> animation,
    required this.onStart,
    required this.isEnabled,
  }) : _animation = animation;

  final GridItemsPositions positions;

  /// Starts the [animation] from 0 to 1
  VoidCallback onStart;

  /// Whether the item should animate the change of its position
  bool isEnabled;

  Animation<double> _animation;
  set animation(Animation<double> value) {
    if (identical(value, _animation)) return;
    if (attached) _animation.removeListener(markNeedsPaint);
    _animation = value;
    if (attached) _animation.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  /// The shift from the new position to the old one at the start of the animation
  Offset _startOffset = Offset.zero;

  /// Whether the animation is scheduled but not started yet
  bool _isWaitingForStart = false;

  /// The position captured before the new layout
  ({Offset layout, Offset visual})? _capturedPosition;

  Offset get _translation =>
      _isWaitingForStart ? _startOffset : _startOffset * (1 - _animation.value);

  /// Remember the current position to compare it with the new one after the layout
  void captureCurrentPosition() {
    if (!attached || !hasSize) return;

    final position = localToGlobal(Offset.zero);
    final captured = (layout: position, visual: position + _translation);
    _capturedPosition = captured;
    markNeedsPaint();

    // The captured position is actual only for the next frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (identical(_capturedPosition, captured)) _capturedPosition = null;
    });
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(markNeedsPaint);
    positions._items.add(this);
  }

  @override
  void detach() {
    // The captured position is not cleared, the item can be reattached in the same frame
    positions._items.remove(this);
    _animation.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final captured = _capturedPosition;
    if (captured != null) {
      _capturedPosition = null;

      // The layout is already done, so the new position is known
      final position = localToGlobal(Offset.zero);
      if (isEnabled && (position - captured.layout).distanceSquared > 0.25) {
        // Keep painting the item at the old place until the animation starts
        _startOffset = captured.visual - position;
        _isWaitingForStart = true;

        // The animation can't be started while painting
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _isWaitingForStart = false;
          if (attached) {
            onStart();
          } else {
            _startOffset = Offset.zero;
          }
        });
      }
    }

    final child = this.child;
    if (child != null) context.paintChild(child, offset + _translation);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintOffset(
      offset: _translation,
      position: position,
      hitTest:
          (result, transformed) =>
              super.hitTestChildren(result, position: transformed),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final translation = _translation;
    transform.multiply(
      Matrix4.translationValues(translation.dx, translation.dy, 0),
    );
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
  late final PreviewPositionsController _previewPositionsController;

  @override
  void initState() {
    super.initState();
    _previewPositionsController = context.read<PreviewPositionsController>();
    _previewPositionsController.addListener(widget.listener);
  }

  @override
  void dispose() {
    _previewPositionsController.removeListener(widget.listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
