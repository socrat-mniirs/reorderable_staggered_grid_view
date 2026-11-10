import 'package:flutter/material.dart';

/// Grid configuration changed in the settings sheet
class GridSettings {
  final bool enableDragging;
  final bool enableLongPress;
  final int crossAxisCount;

  const GridSettings({
    required this.enableDragging,
    required this.enableLongPress,
    required this.crossAxisCount,
  });

  GridSettings copyWith({
    bool? enableDragging,
    bool? enableLongPress,
    int? crossAxisCount,
  }) =>
      GridSettings(
        enableDragging: enableDragging ?? this.enableDragging,
        enableLongPress: enableLongPress ?? this.enableLongPress,
        crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      );
}

/// Show grid settings and actions with items in a bottom sheet
void showSettingsSheet(
  BuildContext context, {
  required GridSettings settings,
  required void Function(GridSettings) onChanged,
  required VoidCallback onAddItem,
  required VoidCallback onRemoveItem,
}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      // The sheet keeps its own copy of the settings to rebuild on changes
      builder: (context, setSheetState) {
        void change(GridSettings value) {
          setSheetState(() => settings = value);
          onChanged(value);
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Long press
                _SwitchConfig(
                  title: 'Long press',
                  value: settings.enableLongPress,
                  onChanged: (value) => change(
                    settings.copyWith(enableLongPress: value),
                  ),
                ),

                // Enable/Disable dragging
                _SwitchConfig(
                  title: 'Dragging',
                  value: settings.enableDragging,
                  onChanged: (value) => change(
                    settings.copyWith(enableDragging: value),
                  ),
                ),

                // Number of columns
                _CrossAxisCountConfig(
                  crossAxisCount: settings.crossAxisCount,
                  onChanged: (value) => change(
                    settings.copyWith(crossAxisCount: value),
                  ),
                ),

                // Remove last & add new
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRemoveItem,
                        icon: const Icon(Icons.clear),
                        label: const Text('Remove last'),
                      ),
                    ),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onAddItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add new'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// On/off config
class _SwitchConfig extends StatelessWidget {
  final String title;
  final bool value;
  final void Function(bool) onChanged;

  const _SwitchConfig({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$title ${value ? 'enabled' : 'disabled'}'),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

// Cross axis count config
class _CrossAxisCountConfig extends StatelessWidget {
  static const _min = 1;

  final int crossAxisCount;
  final void Function(int) onChanged;

  const _CrossAxisCountConfig({
    required this.crossAxisCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Columns'),
        Spacer(),
        IconButton(
          onPressed: crossAxisCount > _min
              ? () => onChanged(crossAxisCount - 1)
              : null,
          icon: const Icon(Icons.remove),
        ),
        Text(crossAxisCount.toString()),
        IconButton(
          onPressed: () => onChanged(crossAxisCount + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
