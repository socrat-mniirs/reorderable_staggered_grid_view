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

  /// The [isLastDraggedItem] define that the item should be animated after reordering or not.
  final bool isLastDraggedItem;

  const AnimatedGridItemWidget({
    required super.key,
    required this.item,
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
  void _scrollEndListener() => capturePosition();

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
            (_) => capturePosition(),
          ),
        );
  }

  @override
  void didUpdateWidget(covariant AnimatedGridItemWidget oldWidget) {
    // Remove animation if this object is the last dragged item
    if (!widget.isLastDraggedItem) {
      startAnimation();
    } else {
      capturePosition();
    }
    super.didUpdateWidget(oldWidget);
  }

  void capturePosition() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      _position = renderBox.localToGlobal(Offset.zero);
    }
  }

  void startAnimation() {
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
              (_) => capturePosition(),
            );
      }
    } catch (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => startAnimation());
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
