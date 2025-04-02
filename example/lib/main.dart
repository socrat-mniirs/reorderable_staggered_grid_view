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
  List<ReorderableStaggeredGridViewItem> items = List.from(
    Constants.reorderableStaggeredGridViewItems,
  );

  bool enableLongPress = false;
  bool enableDragging = true;

  void _addNewItem() {
    final newItem = Constants.generateItem(items.length + 100);
    items.add(newItem);
  }

  void _removeItem() {
    if (items.isNotEmpty) {
      // Necessary to avoid keys duplicates
      final removedIndex = Constants.reorderableStaggeredGridViewItems.indexOf(items.last);
      Constants.animationKeys.remove(removedIndex);
      
      items.removeLast();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          actions: [
            // Switch enable
            Row(
              children: [
                Text('Long press ${enableLongPress ? 'enabled' : 'disabled'}'),
                Switch(
                  value: enableLongPress,
                  onChanged: (value) => setState(() => enableLongPress = value),
                ),
              ],
            ),

            const SizedBox(width: 20),

            // Switch enable
            Row(
              children: [
                Text('Dragging ${enableDragging ? 'enabled' : 'disabled'}'),
                Switch(
                  value: enableDragging,
                  onChanged: (value) => setState(() => enableDragging = value),
                ),
              ],
            ),

            const SizedBox(width: 20),

            // Remove last
            IconButton(
              onPressed: () => setState(_removeItem),
              icon: Icon(Icons.clear),
            ),

            // Add new
            IconButton(
              onPressed: () => setState(_addNewItem),
              icon: Icon(Icons.add),
            ),
          ],
          title: Text('Custom Reorderable Staggered Grid View'),
        ),
        body: ReorderableStaggeredGridView(
          padding: EdgeInsets.all(20),
          enable: enableDragging,
          crossAxisCount: Constants.crossAxisCount,
          mainAxisSpacing: Constants.spacing,
          crossAxisSpacing: Constants.spacing,
          isLongPressDraggable: enableLongPress,
          items: items,
          nonDraggableWidgetsKeys: [Constants.widgetKeys[0]!],
        ),
      ),
    );
  }
}
