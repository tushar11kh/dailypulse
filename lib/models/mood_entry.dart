// lib/models/mood_entry.dart
import 'dart:convert';

class MoodEntry {
  final String id;
  final DateTime date;
  final String emoji;
  final String note;
  final int score; // -1 negative, 0 neutral, 1 positive

  MoodEntry({
    required this.id,
    required this.date,
    required this.emoji,
    required this.note,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'emoji': emoji,
        'note': note,
        'score': score,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> j) => MoodEntry(
        id: j['id'],
        date: DateTime.parse(j['date']),
        emoji: j['emoji'],
        note: j['note'],
        score: j['score'],
      );

  static MoodEntry fromEncoded(String encoded) =>
      MoodEntry.fromJson(jsonDecode(encoded));

  String encode() => jsonEncode(toJson());
}
