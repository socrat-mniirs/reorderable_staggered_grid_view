import 'dart:math';

import 'package:flutter/material.dart';

/// Grid item with a random color
class ItemWidget extends StatelessWidget {
  final int index;
  final bool isDraggable;
  final Color color;

  ItemWidget({
    super.key,
    required this.index,
    required this.isDraggable,
  }) : color = Color.fromRGBO(
          Random().nextInt(255),
          Random().nextInt(255),
          Random().nextInt(255),
          0.5,
        );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: Text(
          isDraggable ? index.toString() : 'Not dragged',
        ),
      ),
    );
  }
}
