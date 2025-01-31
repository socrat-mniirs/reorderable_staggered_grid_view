import 'package:flutter/material.dart';
import 'package:staggered_grid_view/flutter_staggered_grid_view.dart';

import '../reorderable_staggered_grid_view.dart';
import 'widgets/draggable_grid_item.dart';

class ReorderableStaggeredGridView extends StatefulWidget {
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  final EdgeInsets? padding;

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
    this.padding,
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
  late List<StaggeredGridViewItem> items;

  double _dragY = 0;
  bool _isAutoScrolling = false;

  StaggeredGridViewItem? draggingItem;
  StaggeredGridViewItem? beingDraggedItem;

  @override
  void initState() {
    items = widget.items;
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
      padding: widget.padding,
      crossAxisCount: widget.crossAxisCount,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
    
      // CELL SIZE
      staggeredTileBuilder: (index) {
        final item = items[index];
    
        return StaggeredTile.count(
          item.crossAxisCellCount,
          item.mainAxisCellCount.toDouble(),
        );
      },
    
      // ITEMS
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
    
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 150),
          reverseDuration: Duration.zero,
          transitionBuilder: (child, animation) {
            if (
                // Cancel unnecessary repaints when first
                beingDraggedItem != null
                    // Check if objects are equal
                    &&
                    ((child.key as ObjectKey).value as StaggeredGridViewItem)
                            .key ==
                        beingDraggedItem?.key
                    // Check animation duplicates
                    &&
                    animation.status != AnimationStatus.completed) {
              return draggingItem != null ? const SizedBox.shrink() : child;
            }
    
            final mainAxisOffsetCoef = 1 / item.mainAxisCellCount;
            final crossAxisOffsetCoef = 1 / item.crossAxisCellCount;
    
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(
                  0 * crossAxisOffsetCoef,
                  1 * mainAxisOffsetCoef,
                ),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          child: DraggableGridItem(
            key: ObjectKey(item),
            item: item,
            isLongPressDraggable: widget.isLongPressDraggable,
            onDragUpdate: _onDragUpdate,
            onDragEnd: (_) => _stopAutoScroll(),
            onWillAcceptWithDetails: (details) {
              draggingItem = items.firstWhere(
                (el) => el.data == details.data,
              );
              beingDraggedItem = draggingItem;
    
              if (_isAutoScrolling) return false;
    
              if (details.data == item.data) return false;
    
              // items.remove(draggingItem);
              // items.insert(index, draggingItem!);
    
              // setState(() {});
    
              return true;
            },
            onAcceptWithDetails: (details) {
              assert(draggingItem != null);
    
              items.remove(draggingItem);
              items.insert(index, draggingItem!);
    
              setState(() {
                draggingItem = null;
              });
            },
          ),
        );
      },
    );
  }
}
