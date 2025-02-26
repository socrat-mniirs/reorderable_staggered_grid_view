import 'package:flutter/material.dart';

class FeedbackWidget extends StatelessWidget {
  /// The [parentKey] is needed to get the initial size of the grid item, which begins to drag.
  final GlobalKey parentKey;

  /// The [child] is the widget content of the item.
  final Widget child;

  const FeedbackWidget({
    super.key,
    required this.child,
    required this.parentKey,
  });

  @override
  Widget build(BuildContext context) {
    assert(parentKey.currentContext != null);

    // Get initial sizes of the grid item widget
    final itemWidget =
        parentKey.currentContext?.findRenderObject() as RenderBox;
    final size = itemWidget.size;

    return Material(
      elevation: 15,
      shadowColor: Colors.black,
      color: Colors.transparent,
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: child,
      ),
    );
  }
}
