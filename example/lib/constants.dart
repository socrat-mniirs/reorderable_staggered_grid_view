import 'dart:math';

import 'package:example/tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/reorderable_staggered_grid_view.dart';

abstract class Constants {
  static const crossAxisCount = 8;

  static const spacing = 10.0;

  static Map<int, GlobalKey> widgetKeys = {};
  static GlobalKey widgetKeyById(int id) =>
      widgetKeys.putIfAbsent(id, () => GlobalKey());

  static Map<int, GlobalKey> animationKeys = {};
  static GlobalKey animationKeyById(int id) =>
      animationKeys.putIfAbsent(id, () => GlobalKey());

  static final List<ReorderableStaggeredGridViewItem>
      reorderableStaggeredGridViewItems = List.generate(
    100,
    generateItem,
  );

  static ReorderableStaggeredGridViewItem generateItem(dynamic id) {
    final key = widgetKeyById(id);
    final animationKey = animationKeyById(id);

    return ReorderableStaggeredGridViewItem(
      animationKey: animationKey,
      data: id,
      mainAxisCellCount: Random().nextInt(2) + 1,
      crossAxisCellCount: Random().nextInt(2) + 1,
      child: TileWidget(
        key: key,
        title: Text(id == 0 ? 'Not dragged' : id.toString()),
        color: Color.from(
          alpha: 0.1,
          red: Random().nextInt(255).toDouble(),
          green: Random().nextInt(255).toDouble(),
          blue: Random().nextInt(255).toDouble(),
        ),
      ),
    );
  }
}
