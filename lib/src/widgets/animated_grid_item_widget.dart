import 'package:flutter/widgets.dart';
import 'package:reorderable_staggered_grid_view/src/data/reorderable_staggered_grid_view_item.dart';

class AnimatedGridItemWidget extends StatefulWidget {
  final ReorderableStaggeredGridViewItem item;

  const AnimatedGridItemWidget({
    super.key,
    required this.item,
  });

  @override
  State<AnimatedGridItemWidget> createState() => _AnimatedGridItemWidgetState();
}

class _AnimatedGridItemWidgetState extends State<AnimatedGridItemWidget>
    with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero;
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    final crossAxisOffsetCoef = 1 / widget.item.crossAxisCellCount;
    final mainAxisOffsetCoef = 1 / widget.item.mainAxisCellCount;

    // TODO initial animation
    _animation = Tween<Offset>(
      begin: Offset(
        0 * crossAxisOffsetCoef,
        0 * mainAxisOffsetCoef,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // _controller.forward(from: 0)
    // .then(
    //       (_) =>
    //       WidgetsBinding.instance.addPostFrameCallback(
    //         (_) => capturePosition(),
    //       ),
    //     )
    //     ;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => capturePosition(),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedGridItemWidget oldWidget) {
    startAnimation();
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.translate(
        offset: _animation.value,
        child: child,
      ),
      child: widget.item.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
