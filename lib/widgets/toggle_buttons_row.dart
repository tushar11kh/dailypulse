// lib/widgets/toggle_buttons_row.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';

class ToggleButtonsRow extends StatelessWidget {
  final void Function(int)? onSelection;
  final int initialIndex;
  const ToggleButtonsRow({this.onSelection, this.initialIndex = 0, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MoodProvider>();
    final selected = provider.selectedRangeIndex;

    return ToggleButtons(
      onPressed: (i) {
        provider.setSelectedRange(i);
        if (onSelection != null) onSelection!(i);
      },
      isSelected: [selected == 0, selected == 1, selected == 2],
      borderRadius: BorderRadius.circular(30),
      children: const [
        Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Text('Week')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Text('Month')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Text('Year')),
      ],
    );
  }
}
