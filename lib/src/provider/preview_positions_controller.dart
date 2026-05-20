import 'package:flutter/material.dart';

import '../data/reorderable_staggered_grid_item.dart';

class PreviewPositionsController extends ChangeNotifier {
  // Using global keys from original items
  final Map<GlobalKey, Offset> positions = {};

  void update(
    List<ReorderableStaggeredGridItem> items, {
    required GlobalKey Function(
      ReorderableStaggeredGridItem item,
    ) previewItemKey,
  }) {
    positions.clear();

    for (final item in items) {
      final key = previewItemKey(item);
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;

      try {
        final position = renderBox.localToGlobal(Offset.zero);
        positions[item.key] = position;
      } catch (e) {
        // Log error in debug mode
        debugPrint(e.toString());
      }
    }

    notifyListeners();
  }
}
