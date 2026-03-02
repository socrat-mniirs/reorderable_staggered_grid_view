part of 'reorderable_staggered_grid_item_widget.dart';

/// Widget for dragging a grid item
class _GridItemDraggable extends StatelessWidget {
  final Object? data;

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

  // TODO commends
  final Widget childWhenDragging;
  final Widget feedback;
  final Widget child;

  const _GridItemDraggable({
    required this.data,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDragEnd,
    required this.isLongPressDraggable,
    required this.childWhenDragging,
    required this.feedback,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return isLongPressDraggable

        // Long press draggable
        ? LongPressDraggable(
            data: data,
            onDragStarted: onDragStarted,
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd,

            // Child widgets
            feedback: feedback,
            childWhenDragging: childWhenDragging,
            child: child,
          )

        // Default draggable
        : Draggable(
            data: data,
            onDragStarted: onDragStarted,
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd,

            // Child widgets
            feedback: feedback,
            childWhenDragging: childWhenDragging,
            child: child,
          );
  }
}
