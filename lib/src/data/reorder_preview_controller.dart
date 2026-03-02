import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/reorderable_staggered_grid_view.dart';

class ReorderPreviewController extends ChangeNotifier {
  List<ReorderableStaggeredGridViewItem> previewItems = [];

  int? _draggingIndex;

  int? _lastDraggingIndex;
  int? _lastTargetIndex;

  final Map<GlobalKey, GlobalKey> _previewActualKeys = {};
  GlobalKey keyByItem(ReorderableStaggeredGridViewItem item) =>
      _previewActualKeys.putIfAbsent(
        item.key,
        () => GlobalKey(),
      );

  void updateDraggingIndex(int? index) {
    _draggingIndex = index;
  }

  /// Synchronize preview items with actual items
  void syncItems(List<ReorderableStaggeredGridViewItem> items) {
    previewItems = List.of(items);
    notifyListeners();
  }

  /// Reorder items in preview list
  void reorderPreviewItemsOnWillAccept({required int targetIndex}) {
    if (_draggingIndex == null) return;
    if (_draggingIndex == targetIndex) return;

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

    final item = previewItems[_lastTargetIndex!];

    previewItems.removeAt(_lastTargetIndex!);
    previewItems.insert(_lastDraggingIndex!, item);

    _lastDraggingIndex = null;
    _lastTargetIndex = null;

    notifyListeners();
  }
}
