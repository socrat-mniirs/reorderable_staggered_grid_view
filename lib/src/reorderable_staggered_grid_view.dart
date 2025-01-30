import 'package:flutter/material.dart';
import 'package:staggered_grid_view/flutter_staggered_grid_view.dart';

import '../reorderable_staggered_grid_view.dart';

class ReorderableStaggeredGridView extends StatefulWidget {
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  /// The scroll controller for the scroll view
  final ScrollController? controller;
  
  final List<StaggeredGridViewItem> items;
  final bool isLongPressDraggable;

  const ReorderableStaggeredGridView({
    super.key,
    required this.items,
    required this.crossAxisCount,
    required this.isLongPressDraggable,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.controller,
  });

  @override
  State<ReorderableStaggeredGridView> createState() =>
      _ReorderableStaggeredGridViewState();
}

class _ReorderableStaggeredGridViewState
    extends State<ReorderableStaggeredGridView> {
  late final ScrollController _scrollController;

  double _dragY = 0;
  bool _isAutoScrolling = false;

  @override
  void initState() {
    _scrollController = widget.controller ?? ScrollController();
    super.initState();
  }

  // ========== AUTO-SCROLL METHODS ==========

  /// Refresh the Y-position relative to scroll

  void _onDragUpdate(DragUpdateDetails details) {
    _dragY = details.globalPosition.dy;
    _checkAutoScroll();
  }

  /// Start/stop auto-scroll and selecting the auth-scroll direction

  void _checkAutoScroll() {
    final gridHeight = (context.findRenderObject() as RenderBox).size.height;
    const scrollThreshold = 25.0;

    // Up
    if (_dragY < scrollThreshold) {
      _startAutoScroll(up: true);
    }
    // Down
    else if (_dragY > gridHeight - scrollThreshold) {
      _startAutoScroll(up: false);
    }
    // Stop
    else {
      _stopAutoScroll();
    }
  }

  /// Start auto-scroll

  void _startAutoScroll({required bool up}) {
    if (_isAutoScrolling) return;
    _isAutoScrolling = true;

    Future.doWhile(
      () async {
        if (!_isAutoScrolling) return false;
        if (_scrollController.position.outOfRange) return false;

        await _scrollController.animateTo(
          _scrollController.offset + (up ? -50 : 50),
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );

        return _isAutoScrolling;
      },
    );
  }

  /// Stop auto-scroll

  void _stopAutoScroll() => _isAutoScrolling = false;

  /// ====================

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      // Scroll
      controller: _scrollController,

      // UI PARAMS
      padding: EdgeInsets.all(20),
      crossAxisCount: widget.crossAxisCount,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,

      // CELL SIZE
      staggeredTileBuilder: (index) {
        final item = widget.items[index];

        return StaggeredTile.count(
          item.crossAxisCellCount,
          item.mainAxisCellCount.toDouble(),
        );
      },

      // ITEMS
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final itemKey = GlobalKey();

        final dragChild = DraggableGridItem(
          key: itemKey,
          item: item,
        );

        return widget.isLongPressDraggable

            // Long press
            ? LongPressDraggable(
                onDragUpdate: _onDragUpdate,
                onDragEnd: (_) => _stopAutoScroll(),
                data: item.data,
                feedback: FeedbackWidget(
                  parentKey: itemKey,
                  child: item.child,
                ),
                dragAnchorStrategy: pointerDragAnchorStrategy,
                childWhenDragging: const SizedBox.shrink(),
                child: dragChild,
              )

            // Default
            : Draggable(
                onDragUpdate: _onDragUpdate,
                onDragEnd: (_) => _stopAutoScroll(),
                data: item.data,
                feedback: FeedbackWidget(
                  parentKey: itemKey,
                  child: item.child,
                ),
                childWhenDragging: const SizedBox.shrink(),
                child: dragChild,
              );
      },
    );
  }
}
