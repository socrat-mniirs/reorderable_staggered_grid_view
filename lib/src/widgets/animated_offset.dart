import 'package:flutter/material.dart';

/// The [AnimatedOffset] is an [ImplicitlyAnimatedWidget] that can be shifted relating to [offset].
class AnimatedOffset extends ImplicitlyAnimatedWidget {
  /// The [offset] when there is a draggable widget above this drag target. 
  final Offset offset;

  /// The [child] is the widget content of the item.
  final Widget child;

  const AnimatedOffset({
    required this.offset,
    required this.child,
    required super.duration,
    super.curve = Curves.easeInOut,
    super.key,
  });

  @override
  AnimatedOffsetState createState() => AnimatedOffsetState();
}

class AnimatedOffsetState extends AnimatedWidgetBaseState<AnimatedOffset> {
  Tween<Offset>? _offsetTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _offsetTween = visitor(
      _offsetTween,
      widget.offset,
      (dynamic value) => Tween<Offset>(begin: value as Offset),
    ) as Tween<Offset>?;
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offsetTween!.evaluate(animation),
      child: widget.child,
    );
  }
}