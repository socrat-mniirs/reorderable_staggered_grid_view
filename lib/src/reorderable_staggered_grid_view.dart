import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/src/data/scroll_end_notifier.dart';
import 'package:staggered_grid_view/flutter_staggered_grid_view.dart';

import '../reorderable_staggered_grid_view.dart';
import 'widgets/reorderable_staggered_grid_item_widget.dart';

class ReorderableStaggeredGridView extends StatefulWidget {
  /// The scroll [controller] for the scroll view.
  final ScrollController? controller;

  /// The [enable] indicates is dragging enabled or not.
  final bool enable;

  /// The [padding] around the grid view.
  final EdgeInsets? padding;

  /// The [crossAxisCount] is a number of items in the cross-axis of the grid.
  final int crossAxisCount;

  /// The [mainAxisSpacing] is a spacing between elements in the main-axis.
  final double mainAxisSpacing;

  /// The [crossAxisSpacing] is a spacing between elements in the cross-axis.
  final double crossAxisSpacing;

  /// The [physics] of the scroll view.
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the scrollDirection should be determined by the contents being viewed.
  /// Defaults to false, meaning the scroll view expands to fit the parent.
  final bool shrinkWrap;

  /// The axis along which the scroll view scrolls.
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether the scroll view scrolls in the reading direction (false) or in the reverse (true).
  /// Useful for scenarios like chat interfaces or bottom-up lists.
  final bool reverse;

  /// Whether this scroll view is the primary scroll view associated with the parent [PrimaryScrollController].
  /// Should be true when there’s only one scroll view on the screen.
  final bool? primary;

  /// Whether to wrap each child in an [AutomaticKeepAlive].
  /// Defaults to true.
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each child in a [RepaintBoundary].
  /// Typically, children in a scrolling container are wrapped in repaint boundaries
  /// so that they do not need to be repainted as the list scrolls.
  /// If the children are easy to repaint (e.g., solid color blocks or a short snippet of text),
  /// it might be more efficient to not add a repaint boundary and instead always repaint the children during scrolling.
  ///
  /// Defaults to true.
  final bool addRepaintBoundaries;

  /// The [isLongPressDraggable] indicates does it take a long press to drag or not.
  final bool isLongPressDraggable;

  /// The [onDragStarted] called when the draggable starts being dragged.
  final void Function()? onDragStarted;

  /// The [onDragUpdate] called when the draggable is dragged.
  ///
  /// This function will only be called while this widget is still mounted to
  /// the tree (i.e. [State.mounted] is true), and if this widget has actually moved.
  final void Function(DragUpdateDetails details)? onDragUpdate;

  /// The [onDragEnd] called when the draggable is dropped.
  ///
  /// The velocity and offset at which the pointer was moving when it was
  /// dropped is available in the [DraggableDetails]. Also included in the
  /// `details` is whether the draggable's [DragTarget] accepted it.
  ///
  /// This function will only be called while this widget is still mounted to
  /// the tree (i.e. [State.mounted] is true).
  final void Function(DraggableDetails details)? onDragEnd;

  /// The [onWillAcceptWithDetails] called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  final bool Function(DragTargetDetails details)? onWillAcceptWithDetails;

  /// The [onAcceptWithDetails] is a callback when an item is accepted during a drag operation with drag target details
  final void Function(DragTargetDetails details, int newIndex)?
      onAcceptWithDetails;

  /// The [buildFeedbackWidget] is a callback to custom building a feedback widget
  final Widget Function(
          BuildContext context, Widget child, GlobalKey originalWidgetKey)?
      buildFeedbackWidget;

  /// Keys of widgets which cannot be dragged
  final List<Key> nonDraggableWidgetsKeys;

  /// The [willAcceptAnimationOffset] is a callback which calls when there is a draggable widget above another drag target.
  final Duration willAcceptOffsetDuration;

  /// The [willAcceptAnimationOffset] is the animation offset value when dragging widget over another drag target.
  final Offset willAcceptAnimationOffset;

  /// The [items] is a list of items which can be reordered or dragged
  final List<ReorderableStaggeredGridViewItem> items;

  /// The [ReorderableStaggeredGridView] main constructor. Provides lazy rendering of widgets and listening to the end of the scroll.
  const ReorderableStaggeredGridView({
    super.key,
    this.enable = true,
    required this.crossAxisCount,
    this.isLongPressDraggable = false,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.padding,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.controller,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDragEnd,
    this.onWillAcceptWithDetails,
    this.onAcceptWithDetails,
    this.buildFeedbackWidget,
    this.willAcceptOffsetDuration = const Duration(milliseconds: 200),
    this.willAcceptAnimationOffset = const Offset(50, 50),
    this.nonDraggableWidgetsKeys = const [],
    required this.items,
  });

  @override
  State<ReorderableStaggeredGridView> createState() =>
      _ReorderableStaggeredGridViewState();
}

class _ReorderableStaggeredGridViewState
    extends State<ReorderableStaggeredGridView> {
  late final ScrollController _scrollController;
  late List<ReorderableStaggeredGridViewItem> _items;

  double _dragY = 0;
  bool _isAutoScrolling = false;

  ReorderableStaggeredGridViewItem? _draggingItem;
  ReorderableStaggeredGridViewItem? _lastDraggedItem;

  late final ScrollEndNotifier _scrollEndNotifier;

  @override
  void initState() {
    _scrollEndNotifier = ScrollEndNotifier();
    _items = widget.items;
    _scrollController = widget.controller ?? ScrollController();
    super.initState();
  }

  // Update grid if items changed
  @override
  void didUpdateWidget(covariant ReorderableStaggeredGridView oldWidget) {
    if (oldWidget.items.length != widget.items.length ||
        widget.enable != oldWidget.enable) {
      _items = widget.items;
      return;
    }

    super.didUpdateWidget(oldWidget);
  }

  // ========== AUTO-SCROLL METHODS ==========

  /// Refresh the Y-position relative to scroll

  void _autoScrollOnDragUpdate(DragUpdateDetails details) {
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
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        _scrollEndNotifier.scrollEnd();
        return true;
      },

      // The Staggered Grid
      child: StaggeredGridView.countBuilder(
        // Scroll behavior
        controller: _scrollController,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        physics: widget.physics,
        scrollDirection: widget.scrollDirection,
        shrinkWrap: widget.shrinkWrap,
        reverse: widget.reverse,
        primary: widget.primary,

        // UI params
        padding: widget.padding,
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,

        // Cell size
        staggeredTileBuilder: (index) {
          final item = _items[index];

          return StaggeredTile.count(
            item.crossAxisCellCount,
            item.mainAxisCellCount.toDouble(),
          );
        },

        // Items
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];

          // Check that the grid or current item should not be dragged
          if (widget.nonDraggableWidgetsKeys.contains(item.child.key)) {
            return item.child;
          }

          return ReorderableStaggeredGridItemWidget(
            // Items
            item: item,
            draggingItem: _draggingItem,
            isLastDraggedItem: identical(item, _lastDraggedItem),

            // UI
            isDraggingEnabled: widget.enable,
            isLongPressDraggable: widget.isLongPressDraggable,

            // Animation offset
            willAcceptOffsetDuration: widget.willAcceptOffsetDuration,
            willAcceptAnimationOffset: widget.willAcceptAnimationOffset,

            // Feedback widget
            buildFeedbackWidget: widget.buildFeedbackWidget,

            // Dragging + Scroll
            onDragStarted: () {
              _draggingItem = item;
              _lastDraggedItem = item;
              widget.onDragStarted?.call();
            },
            onDragUpdate: (details) {
              _autoScrollOnDragUpdate(details);
              widget.onDragUpdate?.call(details);
            },
            onDragEnd: (details) {
              _stopAutoScroll();
              setState(() => _draggingItem = null);
              widget.onDragEnd?.call(details);
            },
            scrollEndNotifier: _scrollEndNotifier,

            // Accepting
            onWillAcceptWithDetails: (details) {
              if (_isAutoScrolling || details.data == item.data) return false;

              if (widget.onWillAcceptWithDetails != null) {
                return widget.onWillAcceptWithDetails!(details);
              }

              // TODO The functionality below is still in development

              // items.remove(draggingItem);
              // items.insert(index, draggingItem!);

              // setState(() {});

              return true;
            },
            onAcceptWithDetails: (details) {
              assert(_draggingItem != null);

              _items.remove(_draggingItem);
              _items.insert(index, _draggingItem!);

              widget.onAcceptWithDetails?.call(details, index);
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollEndNotifier.dispose();
    super.dispose();
  }
}
