import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_staggered_grid_view/reorderable_staggered_grid_view.dart';

/// Test host with a single column grid of square 100x100 items
class _Host extends StatefulWidget {
  final List<ReorderableStaggeredGridItem> items;
  final void Function(DragTargetDetails details, int newIndex)? onAccept;

  const _Host({required this.items, this.onAccept});

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  void rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 100,
          height: 600,
          child: ReorderableStaggeredGridView.builder(
            crossAxisCount: 1,
            itemCount: widget.items.length,
            itemBuilder: (_, index) => widget.items[index],
            onAcceptWithDetails: (details, newIndex) {
              final item = widget.items.firstWhere(
                (e) => e.data == details.data,
              );
              widget.items.remove(item);
              widget.items.insert(newIndex, item);
              widget.onAccept?.call(details, newIndex);
              setState(() {});
            },
          ),
        ),
      ),
    );
  }
}

ReorderableStaggeredGridItem<int> _item(int id) => ReorderableStaggeredGridItem(
  data: id,
  mainAxisCellCount: 1,
  crossAxisCellCount: 1,
  child: ColoredBox(
    key: ValueKey('child-$id'),
    color: Colors.blue,
    child: Text('$id'),
  ),
);

void main() {
  test('item can be created without child key and childWhenDragging', () {
    expect(
      () => ReorderableStaggeredGridItem(
        data: 0,
        mainAxisCellCount: 1,
        crossAxisCellCount: 1,
        child: const SizedBox(),
      ),
      returnsNormally,
    );
  });

  testWidgets('items animate from old position without a flash frame', (
    tester,
  ) async {
    final items = [_item(0), _item(1), _item(2)];
    await tester.pumpWidget(_Host(items: items));

    Offset topLeftOf(int id) =>
        tester.getTopLeft(find.byKey(ValueKey('child-$id')));

    expect(topLeftOf(0), Offset.zero);
    expect(topLeftOf(2), const Offset(0, 200));

    // Move the last item to the front
    items.insert(0, items.removeLast());
    tester.state<_HostState>(find.byType(_Host)).rebuild();

    // First frame after reorder: items are still painted at the old positions
    await tester.pump();
    expect(topLeftOf(0), Offset.zero);
    expect(topLeftOf(2), const Offset(0, 200));

    // The animation ticker starts counting time from the next frame
    await tester.pump();
    expect(topLeftOf(2), const Offset(0, 200));

    // In the middle of the animation the item is between the old and the new positions
    await tester.pump(const Duration(milliseconds: 100));
    final middle = topLeftOf(2).dy;
    expect(middle, greaterThan(0));
    expect(middle, lessThan(200));

    // After the animation items are at the new positions
    await tester.pumpAndSettle();
    expect(topLeftOf(2), Offset.zero);
    expect(topLeftOf(0), const Offset(0, 100));
    expect(topLeftOf(1), const Offset(0, 200));
  });

  testWidgets('rebuild without reorder does not move items', (tester) async {
    final items = [_item(0), _item(1)];
    await tester.pumpWidget(_Host(items: items));

    tester.state<_HostState>(find.byType(_Host)).rebuild();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('child-1'))),
      const Offset(0, 100),
    );
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('external scroll controller is not disposed by the grid', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ReorderableStaggeredGridView.builder(
          controller: controller,
          crossAxisCount: 1,
          itemCount: 0,
          itemBuilder: (_, _) => throw StateError('No items'),
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox());

    // Throws if the controller has been disposed
    expect(() => controller.addListener(() {}), returnsNormally);
  });

  testWidgets('drag and drop reorders items', (tester) async {
    final items = [_item(0), _item(1), _item(2)];
    int? acceptedIndex;
    await tester.pumpWidget(
      _Host(items: items, onAccept: (_, index) => acceptedIndex = index),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('child-0'))),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(0, 50));
    await tester.pump();
    await gesture.moveTo(const Offset(50, 250));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(acceptedIndex, 2);
    expect(items.map((e) => e.data), [1, 2, 0]);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('child-0'))),
      const Offset(0, 200),
    );
    expect(tester.takeException(), isNull);
  });
}
