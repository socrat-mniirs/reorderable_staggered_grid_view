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

  /// Does it take a long press to drag
  final bool isLongPressDraggable;

  /// Is dragging enabled or not
  final bool enable;

  /// A callback when an item is accepted during a drag operation with drag target details
  final void Function(DragTargetDetails details)? onAcceptWithDetails;

  /// A callback to custom building a feedback widget
  final Widget Function(
          BuildContext context, Widget child, GlobalKey originalWidgetKey)?
      buildFeedbackWidget;

  /// Animation duration
  final Duration duration;

  /// Animation reverse duration
  final Duration reverseDuration;

  /// The [animationOffset] animation duration
  final Duration offsetDuration;

  /// The animation offset when dragging widget over another item
  final Offset animationOffset;

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
    this.enable = true,
    this.duration = const Duration(milliseconds: 150),
    this.reverseDuration = Duration.zero,
    this.offsetDuration = const Duration(milliseconds: 200),
    this.animationOffset = const Offset(50, 50),
    this.buildFeedbackWidget,
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
  StaggeredGridViewItem? lastDraggedItem;

  @override
  void initState() {
    items = widget.items;
    _scrollController = widget.controller ?? ScrollController();
    super.initState();
  }

  // Update grid if children changed
  @override
  void didUpdateWidget(covariant ReorderableStaggeredGridView oldWidget) {
    if (oldWidget.items.length != widget.items.length ||
        widget.enable != oldWidget.enable) {
      items = widget.items;
      return;
    }

    for (int i = 0; i < widget.items.length; i++) {
      if (widget.items[i].key != oldWidget.items[i].key) {
        items = widget.items;
        break;
      }
    }


    super.didUpdateWidget(oldWidget);
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

        // Check that the grid should not be dragged
        if (!widget.enable) {
          return item.child;
        }

        return AnimatedSwitcher(
          // Duration
          duration: widget.duration,
          reverseDuration: widget.reverseDuration,

          // Animation
          transitionBuilder: (child, animation) {
            if (
                // Cancel unnecessary repaints when first
                lastDraggedItem != null
                    // Check if objects are equal
                    &&
                    item.key == lastDraggedItem?.key
                    // Check animation duplicates
                    &&
                    animation.status != AnimationStatus.completed) {
              lastDraggedItem = null;
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

          // Child
          child: DraggableGridItem(
            // Required key to start animation
            key: ObjectKey(item),

            // Is long press need
            isLongPressDraggable: widget.isLongPressDraggable,

            // Auto-scroll
            onDragUpdate: _onDragUpdate,
            onDragEnd: (_) => _stopAutoScroll(),

            // Offset when dragging over
            animationOffset: widget.animationOffset,
            offsetDuration: widget.offsetDuration,

            // Will accept
            onWillAcceptWithDetails: (details) {
              // Draggable data is an item key
              draggingItem = items.firstWhere(
                (el) => el.key == details.data,
              );
              lastDraggedItem = draggingItem;

              if (_isAutoScrolling || details.data == item.key) return false;

              // TODO still in development

              // items.remove(draggingItem);
              // items.insert(index, draggingItem!);

              // setState(() {});

              return true;
            },

            // Accept
            onAcceptWithDetails: (details) {
              assert(draggingItem != null);

              widget.onAcceptWithDetails?.call(details);

              items.remove(draggingItem);
              items.insert(index, draggingItem!);

              setState(() => draggingItem = null);
            },

            // Feedback widget
            buildFeedbackWidget: widget.buildFeedbackWidget,

            // Child
            item: item,
          ),
        );
      },
    );
  }
}
