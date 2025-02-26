import 'dart:math';

import 'package:example/tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/reorderable_staggered_grid_view.dart';

abstract class Constants {
  static const crossAxisCount = 8;

  static const spacing = 10.0;

  static final List<StaggeredGridViewItem> staggeredGridViewItems =
      List.generate(
        100,
        (index) => StaggeredGridViewItem(
          key: ValueKey(index),
          mainAxisCellCount: Random().nextInt(2) + 1,
          crossAxisCellCount: Random().nextInt(2) + 1,
          child: TileWidget(
            title: Text(index.toString()),
            color: Color.from(
              alpha: 0.1,
              red: Random().nextInt(255).toDouble(),
              green: Random().nextInt(255).toDouble(),
              blue: Random().nextInt(255).toDouble(),
            ),
          ),
        ),
      );
}
