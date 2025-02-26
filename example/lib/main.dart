import 'package:example/constants.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_staggered_grid_view/reorderable_staggered_grid_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Custom Reorderable Staggered Grid View'),
        ),
        body: ReorderableStaggeredGridView(
          padding: EdgeInsets.all(20),
          crossAxisCount: Constants.crossAxisCount,
          mainAxisSpacing: Constants.spacing,
          crossAxisSpacing: Constants.spacing,
          isLongPressDraggable: false,
          items: Constants.reorderableStaggeredGridViewItems,
          nonDraggableWidgetsKeys: [ValueKey(0)],
        ),
      ),
    );
  }
}
