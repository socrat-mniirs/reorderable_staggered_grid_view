import 'package:example/constants.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/reorderable_staggered_grid_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<ReorderableStaggeredGridViewItem> items =
      List.from(Constants.reorderableStaggeredGridViewItems);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          actions: [
            // Remove last
            IconButton(
              onPressed: () => setState(() => items.removeLast()),
              icon: Icon(Icons.clear),
            ),

            // Add new
            IconButton(
              onPressed: () => setState(() => items.add(items[1])),
              icon: Icon(Icons.add),
            ),
          ],
          title: Text('Custom Reorderable Staggered Grid View'),
        ),
        body: ReorderableStaggeredGridView(
          padding: EdgeInsets.all(20),
          crossAxisCount: Constants.crossAxisCount,
          mainAxisSpacing: Constants.spacing,
          crossAxisSpacing: Constants.spacing,
          isLongPressDraggable: false,
          items: items,
          nonDraggableWidgetsKeys: [ValueKey(0)],
        ),
      ),
    );
  }
}
