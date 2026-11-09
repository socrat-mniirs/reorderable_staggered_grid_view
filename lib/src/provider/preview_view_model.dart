import 'package:flutter/material.dart';

import '../data/reorderable_staggered_grid_item.dart';

class PreviewViewModel extends ChangeNotifier {
  List<ReorderableStaggeredGridItem> previewItems = [];

  int? _draggingIndex;

  int? _lastDraggingIndex;
  int? _lastTargetIndex;

  bool _isOnAccept = false;
  bool get isOnAccept => _isOnAccept;

  final Map<GlobalKey, GlobalKey> _previewActualKeys = {};
  GlobalKey keyByItem(ReorderableStaggeredGridItem item) =>
      _previewActualKeys.putIfAbsent(
        item.key,
        () => GlobalKey(),
      );

  void updateDraggingIndex(int? index) => _draggingIndex = index;

  /// Synchronize preview items with actual items
  void syncItems(
    List<ReorderableStaggeredGridItem> items, {
    required bool isOnAccept,
  }) {
    previewItems = List.of(items);
    _isOnAccept = isOnAccept;
    notifyListeners();
  }

  /// Reorder items in preview list
  void reorderPreviewItemsOnWillAccept({required int targetIndex}) {
    if (_draggingIndex == null) return;
    if (_draggingIndex == targetIndex) return;

    _isOnAccept = false;
    final item = previewItems[_draggingIndex!];

    previewItems.removeAt(_draggingIndex!);
    previewItems.insert(targetIndex, item);

    _lastDraggingIndex = _draggingIndex;
    _lastTargetIndex = targetIndex;

    notifyListeners();
  }

  /// Canceling reorder operation, restoring original order
  void cancelPreviousReorderChangesOnLeave() {
    if (_lastDraggingIndex == null) return;
    if (_lastTargetIndex == null) return;

    _isOnAccept = false;
    final item = previewItems[_lastTargetIndex!];

    previewItems.removeAt(_lastTargetIndex!);
    previewItems.insert(_lastDraggingIndex!, item);

    _lastDraggingIndex = null;
    _lastTargetIndex = null;

    notifyListeners();
  }
}
