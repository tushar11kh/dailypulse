// lib/pages/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../models/mood_entry.dart';
import '../pages/log_mood_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<MoodEntry> _selectedEntries = [];
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Set current day as selected when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectCurrentDay();
    });
  }

  void _selectCurrentDay() {
    final now = DateTime.now();
    setState(() {
      _selectedDay = now.day;
    });
  }

  String _monthName(int m) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[m - 1];
  }

  String _prettyDate(DateTime d) => '${_monthName(d.month)} ${d.day}, ${d.year}';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MoodProvider>();
    final entries = provider.entries;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Build a map for quick access if needed (not required for multi-entry logic)
    final mapByDay = <int, List<MoodEntry>>{};
    for (var e in entries) {
      if (e.date.year == now.year && e.date.month == now.month) {
        mapByDay.putIfAbsent(e.date.day, () => []).add(e);
      }
    }

    // Update selected entries whenever provider data changes or selected day is set
    if (_selectedDay != null) {
      _selectedEntries = entries.where((e) =>
          e.date.year == now.year && 
          e.date.month == now.month && 
          e.date.day == _selectedDay).toList();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mood Calendar', style: Theme.of(context).appBarTheme.titleTextStyle),
                IconButton(
                  onPressed: () async {
                    // Add new mood entry (for today only). If you want to always allow add for selected day,
                    // you can change this to open LogMoodPage(initialDate: selectedDate)
                    final today = DateTime(now.year, now.month, now.day);
                    final existingToday = mapByDay[today.day];
                    if (existingToday != null && existingToday.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You've already logged today.")));
                      return;
                    }
                    // If you use named routes, adjust accordingly; otherwise push directly:
                    final entry = await Navigator.of(context).push<MoodEntry>(MaterialPageRoute(builder: (_) => LogMoodPage(initialDate: today)));
                    if (entry != null) {
                      await provider.addEntry(entry);
                      // update local map/selection
                      setState(() {
                        _selectedDay = today.day;
                        _selectedEntries = mapByDay[today.day] ?? [];
                        // after adding provider.notifyListeners() already called; rebuild will update.
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(child: Text('${_monthName(now.month)} ${now.year}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((d) => Expanded(child: Center(child: Text(d, style: TextStyle(color: Colors.grey[600])))))
                  .toList(),
            ),
            const SizedBox(height: 6),

            // Calendar grid
            Wrap(
              spacing: 6,
              runSpacing: 10,
              children: List.generate(daysInMonth, (i) {
                final day = i + 1;
                final date = DateTime(now.year, now.month, day);
                final entriesForDay = mapByDay[day] ?? [];
                final isFuture = date.isAfter(DateTime(now.year, now.month, now.day, 23, 59, 59));
                final isSelected = _selectedDay == day;

                final baseColor = entriesForDay.isEmpty
                    ? Colors.grey[200]
                    : (entriesForDay.any((e) => e.score == 1)
                        ? Colors.green[200]
                        : (entriesForDay.any((e) => e.score == -1) ? Colors.red[200] : Colors.yellow[200]));

                final circleColor = isFuture
                    ? Colors.grey[300]
                    : (isSelected ? Colors.deepPurple[200] : baseColor);

                return GestureDetector(
                  onTap: () {
                    if (isFuture) return; // disabled
                    // When tapped, show all logs for that date
                    setState(() {
                      _selectedDay = day;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.deepPurple, width: 2) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isFuture ? Colors.grey[500] : Colors.black87,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Selected date header
            if (_selectedDay != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  '${_monthName(now.month)} $_selectedDay, ${now.year}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

            // Show list of entries for selected day (or 'No entries' message)
            if (_selectedDay != null)
              _selectedEntries.isNotEmpty
                  ? Column(
                      children: _selectedEntries.map((e) {
                        // Only show time if not exactly 00:00
                        final hasNonZeroTime = !(e.date.hour == 0 && e.date.minute == 0);

                        String _formatTime(DateTime dt) {
                          final h = dt.hour.toString().padLeft(2, '0');
                          final m = dt.minute.toString().padLeft(2, '0');
                          return '$h:$m';
                        }

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(radius: 24, backgroundColor: Colors.blue[50], child: Text(e.emoji, style: const TextStyle(fontSize: 22))),
                            title: Text(_labelFromScore(e.score), style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(e.note.isEmpty ? '(No note)' : e.note),
                            trailing: hasNonZeroTime
                                ? Text(_formatTime(e.date), style: const TextStyle(color: Colors.grey))
                                : null,
                          ),
                        );
                      }).toList(),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          Text('No mood entries for this day.', style: TextStyle(color: Colors.grey[700])),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              // open log page for the selected date
                              final date = DateTime(now.year, now.month, _selectedDay!);
                              final entry = await Navigator.of(context).push<MoodEntry>(
                                MaterialPageRoute(builder: (_) => LogMoodPage(initialDate: date)),
                              );
                              if (entry != null) {
                                await provider.addEntry(entry);
                                setState(() {
                                  _selectedEntries = entries.where((e) =>
                                      e.date.year == date.year && e.date.month == date.month && e.date.day == date.day).toList();
                                });
                              }
                            },
                            child: const Text('Add entry for this day'),
                          )
                        ],
                      ),
                    ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  String _labelFromScore(int s) {
    if (s == 1) return 'Happy';
    if (s == -1) return 'Sad';
    return 'Neutral';
  }
}
