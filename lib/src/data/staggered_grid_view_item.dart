import 'package:flutter/material.dart';

class StaggeredGridViewItem {
  final Key key;
  final dynamic data;
  final int mainAxisCellCount;
  final int crossAxisCellCount;
  final Widget child;

  StaggeredGridViewItem({
    required this.key,
    required this.data,
    required this.mainAxisCellCount,
    required this.crossAxisCellCount,
    required this.child,
  });
}
