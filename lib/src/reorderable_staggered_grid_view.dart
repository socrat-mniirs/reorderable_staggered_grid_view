import 'package:flutter/material.dart';
import 'package:staggered_grid_view/flutter_staggered_grid_view.dart';

import '../reorderable_staggered_grid_view.dart';
import 'widgets/draggable_grid_item.dart';

class ReorderableStaggeredGridView extends StatefulWidget {
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  /// The scroll controller for the scroll view
  final ScrollController? controller;

  final List<StaggeredGridViewItem> items;
  final bool isLongPressDraggable;

  /// A callback when an item is accepted during a drag operation with drag target details.
  final void Function(DragTargetDetails details)? onAcceptWithDetails;

  const ReorderableStaggeredGridView({
    super.key,
    required this.items,
    required this.crossAxisCount,
    required this.isLongPressDraggable,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.controller,
    this.onAcceptWithDetails,
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

  /// ========================================

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
        return AnimatedSwitcher(
          duration: Duration(seconds: 1),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 1), 
                end: Offset.zero, 
              ).animate(animation),
              child: child,
            );
          },
          child: DraggableGridItem(
            key: widget.items[index].key,
            item: widget.items[index],
            isLongPressDraggable: widget.isLongPressDraggable,
            onDragUpdate: _onDragUpdate,
            onDragEnd: (_) => _stopAutoScroll(),
            onWillAcceptWithDetails: (details) {
              return details.data != widget.items[index].data;
            },
            onAcceptWithDetails: (details) {
              final draggedItem = widget.items.firstWhere(
                (el) => el.data == details.data,
              );

              widget.items.remove(draggedItem);
              widget.items.insert(index, draggedItem);

              setState(() {});
            },
          ),
        );
      },
    );
  }
}
