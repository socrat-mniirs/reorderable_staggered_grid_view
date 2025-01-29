import 'package:flutter/material.dart';

class FeedbackWidget extends StatelessWidget {
  final Widget child;
  final GlobalKey parentKey;

  const FeedbackWidget({
    super.key,
    required this.child,
    required this.parentKey,
  });

  @override
  Widget build(BuildContext context) {
    assert(parentKey.currentContext != null);
    final itemWidget =
        parentKey.currentContext?.findRenderObject() as RenderBox;
    final size = itemWidget.size;

    return Material(
      elevation: 15,
      shadowColor: Colors.black,
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: child,
      ),
    );
  }
}
