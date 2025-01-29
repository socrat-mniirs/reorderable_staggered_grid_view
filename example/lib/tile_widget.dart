import 'package:flutter/material.dart';

class TileWidget extends StatelessWidget {
  final Widget title;
  final Color color;

  const TileWidget({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black),
      ),
      child: Center(child: title),
    );
  }
}
