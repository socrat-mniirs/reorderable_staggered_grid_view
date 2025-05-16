import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/src/data/scroll_end_notifier.dart';
import 'package:reorderable_staggered_grid_view/src/widgets/animated_grid_item_widget.dart';

import '../data/reorderable_staggered_grid_view_item.dart';
import 'animated_offset.dart';

class DraggableGridItem extends StatefulWidget {
  /// The [item] is a grid widget that can be reordered or dragged.
  final ReorderableStaggeredGridViewItem item;

  /// The [isLastDraggedItem] define that the item should be animated after reordering or not.
  final bool isLastDraggedItem;

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

  /// The [onAcceptWithDetails] called when an acceptable piece of data was dropped over this drag target.
  /// It will not be called if `data` is `null`.
  final void Function(DragTargetDetails<Object?> details)? onAcceptWithDetails;

  /// The [onWillAcceptWithDetails] called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  final bool Function(DragTargetDetails<Object?> details)?
      onWillAcceptWithDetails;

  /// The animation offset on [onWillAcceptWithDetails].
  final Offset animationOffset;

  /// The [offsetDuration] is an animation duration of [animationOffset].
  final Duration offsetDuration;

  /// The [buildFeedbackWidget] called when the dragging started to paint widget which will be shown as a dragging widget.
  final Widget Function(
          BuildContext context, Widget child, GlobalKey originalWidgetKey)?
      buildFeedbackWidget;

  /// The [scrollEndNotifier] notify animated grid items about end of scroll to recalculate their positions on the screen.
  final ScrollEndNotifier scrollEndNotifier;

  /// The [originalWidgetKey] using to get original sizes when building feedback widget.
  /// Not using when [buildFeedbackWidget] is not equal to NULL.
  final originalWidgetKey = GlobalKey();

  DraggableGridItem({
    super.key,
    required this.item,
    required this.isLastDraggedItem,
    this.isLongPressDraggable = false,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDragEnd,
    this.onAcceptWithDetails,
    this.onWillAcceptWithDetails,
    this.animationOffset = const Offset(50, 50),
    this.offsetDuration = const Duration(milliseconds: 200),
    this.buildFeedbackWidget,
    required this.scrollEndNotifier,
  });

  @override
  State<DraggableGridItem> createState() => _DraggableGridItemState();
}

class _DraggableGridItemState extends State<DraggableGridItem> {
  Offset offset = Offset.zero;

  /// [_onLeave] - return the target object to its original place
  ///
  void _onLeave(Object? data) {
    if (data == widget.item.data) {
      return;
    }

    setState(() => offset -= widget.animationOffset);
  }

  /// [_onWillAcceptWithDetails] - shifts the object, indicating that it is ready to replace another grid element
  ///
  bool _onWillAcceptWithDetails(DragTargetDetails<Object?> details) {
    if (details.data == widget.item.data) {
      return false;
    }

    setState(() => offset += widget.animationOffset);

    return widget.onWillAcceptWithDetails?.call(details) ?? true;
  }

  /// [_onAcceptWithDetails] - calling the passed function
  ///
  void _onAcceptWithDetails(DragTargetDetails<Object?> details) =>
      widget.onAcceptWithDetails?.call(details);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated draggable widget (above drag target)
        AnimatedOffset(
          duration: widget.offsetDuration,
          offset: offset,
          child: widget.isLongPressDraggable

              // ===== LONG PRESS =====

              ? LongPressDraggable(
                  data: widget.item.data,
                  onDragStarted: widget.onDragStarted,
                  onDragUpdate: widget.onDragUpdate,
                  onDragEnd: widget.onDragEnd,
                  childWhenDragging: TickerMode(
                    enabled: false,
                    child: AnimatedGridItemWidget(
                      key: widget.item.animationKey,
                      scrollEndNotifier: widget.scrollEndNotifier,
                      item: null,
                    ),
                  ),
                  feedback: FeedbackWidget(
                    buildFeedbackWidget: widget.buildFeedbackWidget,
                    originalWidgetKey: widget.originalWidgetKey,
                    child: widget.item.child,
                  ),

                  // Child
                  child: SizedBox(
                    key: widget.originalWidgetKey,
                    child: AnimatedGridItemWidget(
                      key: widget.item.animationKey,
                      scrollEndNotifier: widget.scrollEndNotifier,
                      isLastDraggedItem: widget.isLastDraggedItem,
                      item: widget.item,
                    ),
                  ),
                )

              // ===== DEFAULT PRESS =====

              : Draggable(
                  data: widget.item.data,
                  onDragStarted: widget.onDragStarted,
                  onDragUpdate: widget.onDragUpdate,
                  onDragEnd: widget.onDragEnd,
                  childWhenDragging: TickerMode(
                    enabled: false,
                    child: AnimatedGridItemWidget(
                      key: widget.item.animationKey,
                      scrollEndNotifier: widget.scrollEndNotifier,
                      item: null,
                    ),
                  ),
                  feedback: FeedbackWidget(
                    buildFeedbackWidget: widget.buildFeedbackWidget,
                    originalWidgetKey: widget.originalWidgetKey,
                    child: widget.item.child,
                  ),

                  // Child
                  child: SizedBox(
                    key: widget.originalWidgetKey,
                    child: AnimatedGridItemWidget(
                      key: widget.item.animationKey,
                      scrollEndNotifier: widget.scrollEndNotifier,
                      isLastDraggedItem: widget.isLastDraggedItem,
                      item: widget.item,
                    ),
                  ),
                ),
        ),

        // Drag target (under the draggable widget)
        Positioned.fill(
          child: DragTarget(
            onLeave: _onLeave,
            onWillAcceptWithDetails: _onWillAcceptWithDetails,
            onAcceptWithDetails: _onAcceptWithDetails,
            builder: (context, _, __) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

/// Feedback widget
class FeedbackWidget extends StatelessWidget {
  final GlobalKey originalWidgetKey;

  final Widget Function(
    BuildContext context,
    Widget child,
    GlobalKey originalWidgetKey,
  )? buildFeedbackWidget;

  final Widget child;

  const FeedbackWidget({
    super.key,
    required this.buildFeedbackWidget,
    required this.child,
    required this.originalWidgetKey,
  });

  @override
  Widget build(BuildContext context) {
    /// ===== CUSTOM BUILD =====
    ///
    if (buildFeedbackWidget != null) {
      return buildFeedbackWidget!(
        context,
        child,
        originalWidgetKey,
      );
    }

    /// ===== DEFAULT BUILD =====
    ///
    assert(originalWidgetKey.currentContext != null);

    // Get initial sizes of the grid item widget
    final itemWidget =
        originalWidgetKey.currentContext?.findRenderObject() as RenderBox;
    final size = itemWidget.size;

    return Material(
      elevation: 15,
      shadowColor: Colors.black,
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: child,
      ),
    );
  }
}
