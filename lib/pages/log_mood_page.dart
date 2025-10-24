// lib/pages/log_mood_page.dart
import 'package:flutter/material.dart';
import '../models/mood_entry.dart';

class LogMoodPage extends StatefulWidget {
  final DateTime? initialDate;
  const LogMoodPage({Key? key, this.initialDate}) : super(key: key);

  @override
  _LogMoodPageState createState() => _LogMoodPageState();
}

class _LogMoodPageState extends State<LogMoodPage> {
  final _noteController = TextEditingController();
  String _selectedEmoji = '😊';
  int _selectedScore = 1;
  late DateTime _date;

  final List<Map<String, dynamic>> moods = [
    {'emoji': '😊', 'score': 1},
    {'emoji': '😔', 'score': -1},
    {'emoji': '😡', 'score': -1},
    {'emoji': '😌', 'score': 1},
    {'emoji': '😴', 'score': 0},
  ];

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();
    _selectedEmoji = moods[0]['emoji'];
    _selectedScore = moods[0]['score'];
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveAndReturn() {
    final entry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _date,
      emoji: _selectedEmoji,
      note: _noteController.text.trim(),
      score: _selectedScore,
    );
    Navigator.of(context).pop(entry);
  }

  Widget _moodButton(String emoji, int score) {
    final selected = emoji == _selectedEmoji;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedEmoji = emoji;
        _selectedScore = score;
      }),
      child: Column(
        children: [
          CircleAvatar(
            radius: selected ? 34 : 28,
            backgroundColor: selected ? Colors.blue[50] : Colors.grey[200],
            child: Text(emoji, style: TextStyle(fontSize: selected ? 38 : 34)),
          ),
          SizedBox(height: 6),
          if (selected) Text('Selected', style: TextStyle(color: Colors.deepPurple, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('How are you feeling today?'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          children: [
            Align(alignment: Alignment.centerLeft, child: Text('Today, ${_date.day}/${_date.month}/${_date.year}', style: TextStyle(color: Colors.grey[700]))),
            SizedBox(height: 12),
            Text('Select your mood', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600)),
            SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: moods.map((m) => _moodButton(m['emoji'], m['score'] as int)).toList(),
            ),
            SizedBox(height: 21),
            Align(alignment: Alignment.center, child: Text('Add a note (optional)', style: TextStyle(color: Colors.blueGrey[700], fontWeight: FontWeight.w600))),
            SizedBox(height: 10),
            Expanded(
              child: TextField(
                style: TextStyle(color: Colors.black),
                controller: _noteController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _saveAndReturn,
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
              child: Text('Log My Mood', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )
          ],
        ),
      ),
    );
  }
}
