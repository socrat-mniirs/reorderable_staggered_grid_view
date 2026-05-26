import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_staggered_grid_view/src/widgets/animated_grid_item_widget.dart';
import 'package:staggered_grid_view/flutter_staggered_grid_view.dart';

import 'provider/scroll_end_notifier.dart';
import 'provider/preview_positions_controller.dart';
import 'provider/preview_view_model.dart';
import 'data/reorderable_staggered_grid_mode.dart';
import 'data/reorderable_staggered_grid_item.dart';
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

  /// The [onMove] called when draggable moving within drag target.
  final void Function(DragTargetDetails details)? onMove;

  /// The [onLeave] called when a given piece of data being dragged over this target leaves
  /// the target.
  final void Function(Object? data)? onLeave;

  /// The [onWillAcceptWithDetails] called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  final bool Function(DragTargetDetails details)? onWillAcceptWithDetails;

  /// The [onAcceptWithDetails] is a callback when an item is accepted during a drag operation with drag target details
  final void Function(DragTargetDetails details, int newIndex)?
  onAcceptWithDetails;

  /// The [buildFeedbackWidget] is a callback to custom building a feedback widget
  final Widget Function(
    BuildContext context,
    Widget child,
    Size originalWidgetSize,
  )?
  buildFeedbackWidget;

  /// The [onWillAcceptDuration] is the delay before the animation which indicates that the rebuild will be accepted.
  final Duration? onWillAcceptDuration;

  /// The [willAcceptAnimationOffset] is a callback which calls when there is a draggable widget above another drag target.
  final Duration willAcceptOffsetDuration;

  /// The [willAcceptAnimationOffset] is the animation offset value when dragging widget over another drag target.
  final Offset willAcceptAnimationOffset;

  /// The [items] is a list of items which can be reordered or dragged
  final List<ReorderableStaggeredGridItem> items;

  /// The [itemBuilder] builds and returns a [ReorderableStaggeredGridItem] for the given index.
  /// This callback is used to lazily create grid items during layout building.
  final ReorderableStaggeredGridItem Function(BuildContext context, int index)
  itemBuilder;

  /// The total number of items that can be built by [itemBuilder].
  /// If null, the length of [items] will be used instead.
  final int? itemCount;

  /// The [mode] of the reorderable staggered grid view.
  final ReorderableStaggeredGridMode mode;

  /// The [ReorderableStaggeredGridView] main constructor. Provides lazy rendering of widgets.
  const ReorderableStaggeredGridView.builder({
    super.key,
    required this.crossAxisCount,
    required this.itemBuilder,
    this.itemCount,
    this.enable = true,
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
    this.onMove,
    this.onLeave,
    this.onWillAcceptWithDetails,
    this.onAcceptWithDetails,
    this.buildFeedbackWidget,
    this.willAcceptOffsetDuration = const Duration(milliseconds: 200),
    this.willAcceptAnimationOffset = Offset.zero,
  }) : // Setting mode to normal
       mode = ReorderableStaggeredGridMode.builder,

       // Fill unused parameters
       items = const [],
       onWillAcceptDuration = null;

  // TODO Preview functionality is hidden yet
  /// Provides lazy rendering of widgets and preview of reorder operation.
  // const ReorderableStaggeredGridView.buildWithReorderPreview({
  //   super.key,
  //   this.enable = true,
  //   required this.crossAxisCount,
  //   this.isLongPressDraggable = false,
  //   this.physics,
  //   this.shrinkWrap = false,
  //   this.scrollDirection = Axis.vertical,
  //   this.reverse = false,
  //   this.primary,
  //   this.addAutomaticKeepAlives = true,
  //   this.addRepaintBoundaries = true,
  //   this.padding,
  //   this.mainAxisSpacing = 0,
  //   this.crossAxisSpacing = 0,
  //   this.controller,
  //   this.onDragStarted,
  //   this.onDragUpdate,
  //   this.onDragEnd,
  //   this.onMove,
  //   this.onLeave,
  //   this.onWillAcceptWithDetails,
  //   this.onAcceptWithDetails,
  //   this.buildFeedbackWidget,
  //   this.onWillAcceptDuration = Durations.long2,
  //   this.itemCount,
  //   required this.items,
  //   required this.itemBuilder,
  // })  :
  //       // Setting mode to withReorderPreview
  //       mode = ReorderableStaggeredGridMode.buildWithReorderPreview,

  //       // Unused params with reorder preview
  //       willAcceptAnimationOffset = Offset.zero,
  //       willAcceptOffsetDuration = Duration.zero;

  @override
  State<ReorderableStaggeredGridView> createState() =>
      _ReorderableStaggeredGridViewState();
}

class _ReorderableStaggeredGridViewState
    extends State<ReorderableStaggeredGridView> {
  final _previewViewModel = PreviewViewModel();
  final _previewPositionsController = PreviewPositionsController();

  late final ScrollController _scrollController;

  late List<ReorderableStaggeredGridItem> _items;

  // Autoscroll fields
  double _dragY = 0;
  bool _isAutoScrolling = false;

  ReorderableStaggeredGridItem? _lastDraggedItem;

  late final ScrollEndNotifier _scrollEndNotifier;

  @override
  void initState() {
    super.initState();

    // Items
    _items = widget.items;

    // Scroll
    _scrollEndNotifier = ScrollEndNotifier();
    _scrollController = widget.controller ?? ScrollController();

    // Reordering items on will accept
    _previewViewModel.syncItems(_items, isOnAccept: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollEndNotifier.dispose();
    super.dispose();
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

    Future.doWhile(() async {
      if (!_isAutoScrolling) return false;
      if (_scrollController.position.outOfRange) return false;

      await _scrollController.animateTo(
        _scrollController.offset + (up ? -50 : 50),
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );

      return _isAutoScrolling;
    });
  }

  /// Stop auto-scroll
  void _stopAutoScroll() => _isAutoScrolling = false;

  /// ========================================

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _previewViewModel,
      child: ChangeNotifierProvider.value(
        value: _previewPositionsController,
        child: ChangeNotifierProvider.value(
          value: _scrollEndNotifier,

          // Listen to scroll end notifications
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (notification) {
              _scrollEndNotifier.scrollEnd();
              return true;
            },

            // Staggered Grid
            child: Stack(
              children: [
                // Main grid
                StaggeredGridView.countBuilder(
                  // Scroll behavior
                  controller: _scrollController,
                  primary: widget.primary,
                  physics: widget.physics,
                  reverse: widget.reverse,
                  shrinkWrap: widget.shrinkWrap,
                  scrollDirection: widget.scrollDirection,
                  addRepaintBoundaries: widget.addRepaintBoundaries,
                  addAutomaticKeepAlives: widget.addAutomaticKeepAlives,

                  // UI params
                  padding: widget.padding,
                  crossAxisCount: widget.crossAxisCount,
                  mainAxisSpacing: widget.mainAxisSpacing,
                  crossAxisSpacing: widget.crossAxisSpacing,

                  // Cell size
                  staggeredTileBuilder: (index) {
                    final item = widget.itemBuilder(context, index);
                    return StaggeredTile.count(
                      item.crossAxisCellCount,
                      item.mainAxisCellCount.toDouble(),
                    );
                  },

                  // Items
                  itemCount: widget.itemCount ?? _items.length,
                  itemBuilder: (context, index) {
                    final item = widget.itemBuilder(context, index);
                    final isLastDraggedItem = item == _lastDraggedItem;

                    // Check that the grid or current item should not be dragged
                    if (!widget.enable || !item.isDraggable) {
                      return AnimatedGridItemWidget(
                        key: item.key,
                        item: item,
                        mode: widget.mode,
                        isLastDraggedItem: isLastDraggedItem,
                      );
                    }

                    return ReorderableStaggeredGridItemWidget(
                      // Item
                      item: item,
                      index: index,
                      isLastDraggedItem: isLastDraggedItem,

                      // Grid mode
                      mode: widget.mode,

                      // UI
                      scrollEndNotifier: _scrollEndNotifier,
                      isLongPressDraggable: widget.isLongPressDraggable,

                      // Animation offset
                      onWillAcceptDuration: widget.onWillAcceptDuration,
                      willAcceptOffsetDuration: widget.willAcceptOffsetDuration,
                      willAcceptAnimationOffset:
                          widget.willAcceptAnimationOffset,

                      // Feedback widget
                      buildFeedbackWidget: widget.buildFeedbackWidget,

                      // On drag started
                      onDragStarted: () {
                        _lastDraggedItem = item;
                        _previewViewModel.updateDraggingIndex(index);

                        widget.onDragStarted?.call();
                      },

                      // On move
                      onMove: widget.onMove,

                      // On drag update
                      onDragUpdate: (details) {
                        _autoScrollOnDragUpdate(details);
                        widget.onDragUpdate?.call(details);
                      },

                      // On leave
                      onLeave: widget.onLeave,

                      // On drag end
                      onDragEnd: (details) {
                        _stopAutoScroll();
                        _previewViewModel.updateDraggingIndex(null);
                        widget.onDragEnd?.call(details);
                      },

                      // Will accept
                      onWillAcceptWithDetails: (details) {
                        if (_isAutoScrolling) return false;
                        if (details.data == item.data) return false;

                        return widget.onWillAcceptWithDetails?.call(details) ??
                            true;
                      },

                      // Accept
                      onAcceptWithDetails: (details) {
                        // Sync preview items
                        if (widget.mode ==
                            ReorderableStaggeredGridMode
                                .buildWithReorderPreview) {
                          _previewViewModel.syncItems(_items, isOnAccept: true);
                        }

                        widget.onAcceptWithDetails?.call(details, index);
                      },
                    );
                  },
                ),

                // Invisible preview grid for calculating positions
                if (widget.mode ==
                    ReorderableStaggeredGridMode.buildWithReorderPreview)
                  IgnorePointer(
                    child: Offstage(
                      child: _PreviewGrid(
                        mainGridScrollController: _scrollController,
                        physics: widget.physics,
                        reverse: widget.reverse,
                        padding: widget.padding,
                        primary: widget.primary,
                        shrinkWrap: widget.shrinkWrap,
                        scrollDirection: widget.scrollDirection,
                        addRepaintBoundaries: widget.addRepaintBoundaries,
                        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
                        crossAxisCount: widget.crossAxisCount,
                        mainAxisSpacing: widget.mainAxisSpacing,
                        crossAxisSpacing: widget.crossAxisSpacing,
                        itemCount: widget.itemCount,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Invisible grid to catch preview items positions
class _PreviewGrid extends StatefulWidget {
  final ScrollController mainGridScrollController;
  final EdgeInsets? padding;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;
  final bool reverse;
  final bool? primary;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final int? itemCount;

  const _PreviewGrid({
    this.padding,
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    this.physics,
    required this.shrinkWrap,
    required this.scrollDirection,
    required this.reverse,
    this.primary,
    required this.addAutomaticKeepAlives,
    required this.addRepaintBoundaries,
    required this.mainGridScrollController,
    required this.itemCount,
  });

  @override
  State<_PreviewGrid> createState() => _PreviewGridState();
}

class _PreviewGridState extends State<_PreviewGrid> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController(
      initialScrollOffset: widget.mainGridScrollController.position.pixels,
    );

    widget.mainGridScrollController.addListener(
      _mainGridScrollControllerListener,
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.mainGridScrollController.removeListener(
      _mainGridScrollControllerListener,
    );
    _scrollController.dispose();
  }

  void _mainGridScrollControllerListener() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(widget.mainGridScrollController.offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PreviewViewModel>(
      builder: (context, state, child) {
        final items = state.previewItems;

        // Update preview items positions
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.read<PreviewPositionsController>().update(
            items,
            keyByItem: state.keyByItem,
            animateItemsByNewPreviewPositions: !state.isOnAccept,
          ),
        );

        // Preview staggered grid
        return StaggeredGridView.countBuilder(
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
          staggeredTileBuilder:
              (index) => StaggeredTile.count(
                items[index].crossAxisCellCount,
                items[index].mainAxisCellCount.toDouble(),
              ),

          // Items
          itemCount: widget.itemCount,
          itemBuilder:
              (context, index) => _PreviewItem(
                key: UniqueKey(),
                items[index],
              ),
        );
      },
    );
  }
}

/// Preview item widget to get its position
class _PreviewItem extends StatefulWidget {
  final ReorderableStaggeredGridItem item;

  const _PreviewItem(this.item, {super.key});

  @override
  State<_PreviewItem> createState() => __PreviewItemState();
}

class __PreviewItemState extends State<_PreviewItem> {
  late final PreviewViewModel _previewViewModel;
  late final PreviewPositionsController _previewPositionsController;

  late final GlobalKey _key;

  @override
  void initState() {
    super.initState();
    _previewViewModel = context.read<PreviewViewModel>();
    _previewPositionsController = context.read<PreviewPositionsController>();

    _key = _previewViewModel.keyByItem(widget.item);

    // Capture position after initial build
    WidgetsBinding.instance.addPostFrameCallback((_) => _capturePosition());
  }

  @override
  void didUpdateWidget(covariant _PreviewItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _capturePosition());
  }

  // Save item position to PreviewOffsetNotifier
  void _capturePosition() {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      // TODO тоже интересное место, стремно так изменять основной список
      // Save item position without notifying listeners
      final position = renderBox.localToGlobal(Offset.zero);
      _previewPositionsController.positions[widget.item.key] = position;
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox.shrink(key: _key);
}
