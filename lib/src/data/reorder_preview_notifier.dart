import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/reorderable_staggered_grid_view.dart';

class ReorderPreviewNotifier extends ChangeNotifier {
  // Using global keys from original items
  final Map<GlobalKey, Offset> positions = {};

  void update(
    List<ReorderableStaggeredGridViewItem> items, {
    required GlobalKey Function(
      ReorderableStaggeredGridViewItem item,
    ) previewItemKey,
  }) {
    positions.clear();

    for (final item in items) {
      final key = previewItemKey(item);
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;

      try {
        final position = renderBox.localToGlobal(Offset.zero);
        positions[item.animationKey] = position;
      } catch (_) {
        // TODO
        // Should log?
      }
    }

    notifyListeners();
  }
}
