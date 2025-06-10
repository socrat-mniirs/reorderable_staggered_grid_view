import 'package:flutter/widgets.dart';
import 'package:reorderable_staggered_grid_view/src/data/reorderable_staggered_grid_view_item.dart';
import 'package:reorderable_staggered_grid_view/src/data/scroll_end_notifier.dart';

/// The [AnimatedGridItemWidget] is a widget that will be animated from its
/// old position on the screen to its new position in grid after
/// changing its index in an array of parent grid.
///
/// Animation works only if passed widget Key (GlobalKey recommended).
class AnimatedGridItemWidget extends StatefulWidget {
  /// The [scrollEndNotifier] notify animated grid items about end of scroll to recalculate their positions on the screen.
  final ScrollEndNotifier scrollEndNotifier;

  /// The [item] is a grid widget that can be reordered or dragged.
  final ReorderableStaggeredGridViewItem? item;

  /// The [index] determines whether the position of the element in the grid has changed and whether animation needs to be started.
  final int index;

  /// The [isLastDraggedItem] define that the item should be animated after reordering or not.
  final bool isLastDraggedItem;

  const AnimatedGridItemWidget({
    required super.key,
    required this.item,
    required this.index,
    this.isLastDraggedItem = false,
    required this.scrollEndNotifier,
  });

  @override
  State<AnimatedGridItemWidget> createState() => _AnimatedGridItemWidgetState();
}

class _AnimatedGridItemWidgetState extends State<AnimatedGridItemWidget>
    with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero;

  // Animation
  late AnimationController _controller;
  late Animation<Offset> _animation;

  // Recalculation of positions after scroll completion
  void _scrollEndListener() => _capturePosition();

  @override
  void initState() {
    super.initState();

    // Recalculation of positions after scroll completion
    widget.scrollEndNotifier.addListener(_scrollEndListener);

    _controller = AnimationController(
      vsync: this,
      duration: widget.item?.duration ?? Duration(milliseconds: 300),
    );

    _animation = Tween<Offset>(
      begin: widget.item?.startingOffset ??
          Offset(
            0 * (1 / (widget.item?.crossAxisCellCount ?? 1)),
            100 * (1 / (widget.item?.mainAxisCellCount ?? 1)),
          ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.item?.curve ?? Curves.easeOut,
      ),
    );

    _controller.forward(from: 0).then(
          (_) => WidgetsBinding.instance.addPostFrameCallback(
            (_) => _capturePosition(),
          ),
        );
  }

  @override
  void didUpdateWidget(covariant AnimatedGridItemWidget oldWidget) {
    // Check if animation is necessary and proceed to actions
    if (_isAnimationNeeded(oldWidget)) {
      _startAnimation();
    } else {
      _capturePosition();
    }

    super.didUpdateWidget(oldWidget);
  }

  // Check if animation is needed.
  // Do not start animation if this item is last dragged or its index in grid has not changed.
  bool _isAnimationNeeded(covariant AnimatedGridItemWidget oldWidget) {
    if (widget.isLastDraggedItem) {
      return false;
    }

    if (widget.index == oldWidget.index) {
      return false;
    }

    return true;
  }

  // Saving the current position of the grid element
  void _capturePosition() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      _position = renderBox.localToGlobal(Offset.zero);
    }
  }

  // Animating the grid element to a new position and saving the current position after that
  void _startAnimation() {
    try {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final newPosition = renderBox.localToGlobal(Offset.zero);
        final delta = _position - newPosition;

        setState(
          () {
            _animation = Tween<Offset>(
              begin: Offset(delta.dx, delta.dy),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOut,
              ),
            );
          },
        );

        _controller.forward(from: 0).then(
              (_) => _capturePosition(),
            );
      }
    } catch (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.translate(
        offset: _animation.value,
        child: child,
      ),
      child: widget.item!.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.scrollEndNotifier.removeListener(_scrollEndListener);
    super.dispose();
  }
}
