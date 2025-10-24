// lib/providers/mood_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_entry.dart';
import '../services/storage_service.dart';

class MoodProvider extends ChangeNotifier {
  final StorageService _storage;
  final List<MoodEntry> _entries = [];
  int _selectedRangeIndex = 0;
  User? _user; // current Firebase user

  MoodProvider({StorageService? storage}) : _storage = storage ?? StorageService();

  void updateUser(User? user) {
    _user = user;
    if (user != null) {
      _load(); // load user-specific data when logged in
    } else {
      clearData(); // clear on logout
    }
  }

  int get selectedRangeIndex => _selectedRangeIndex;
  void setSelectedRange(int index) {
    if (index < 0 || index > 2) return;
    _selectedRangeIndex = index;
    notifyListeners();
  }

  List<MoodEntry> get entries => List.unmodifiable(_entries);

  Future<void> _load() async {
    if (_user == null) return;

    // 1. Load from Firestore if available
    final cloudList = await _storage.loadListFromFirestore(_user!.uid);
    if (cloudList.isNotEmpty) {
      _entries
        ..clear()
        ..addAll(cloudList.map((s) => MoodEntry.fromEncoded(s)));
      await _storage.saveList(cloudList); // update local cache
    } else {
      // 2. If Firestore empty, load from local
      final localList = await _storage.loadList();
      _entries
        ..clear()
        ..addAll(localList.map((s) => MoodEntry.fromEncoded(s)));
    }

    _entries.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addEntry(MoodEntry entry) async {
    if (_user == null) return;

    _entries.insert(0, entry);
    await _save();
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    if (_user == null) return;

    _entries.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final encoded = _entries.map((e) => e.encode()).toList();
    await _storage.saveList(encoded); // local save
    if (_user != null) {
      await _storage.saveListToFirestore(_user!.uid, encoded); // cloud sync
    }
  }

  Future<void> clearData() async {
    _entries.clear();
    await _storage.clearLocal();
    notifyListeners();
  }

  // ------- Range helpers -------
  int _rangeToDays(int idx) => idx == 0 ? 7 : (idx == 1 ? 30 : 365);

  List<MoodEntry> get filteredEntries {
    final days = _rangeToDays(_selectedRangeIndex);
    final cutoff = DateTime.now().subtract(Duration(days: days - 1));
    return _entries.where((e) => !e.date.isBefore(DateTime(cutoff.year, cutoff.month, cutoff.day))).toList();
  }

  int get totalForSelectedRange => filteredEntries.length;
  int get positivesForSelectedRange => filteredEntries.where((e) => e.score == 1).length;
  int get negativesForSelectedRange => filteredEntries.where((e) => e.score == -1).length;
  int get neutralsForSelectedRange => filteredEntries.where((e) => e.score == 0).length;

  List<MoodEntry> lastNDaysForSelectedRange() {
    final n = _rangeToDays(_selectedRangeIndex);
    final today = DateTime.now();
    return List.generate(n, (i) {
      final day = DateTime(today.year, today.month, today.day).subtract(Duration(days: n - 1 - i));
      return _entries.firstWhere(
        (e) => e.date.year == day.year && e.date.month == day.month && e.date.day == day.day,
        orElse: () => MoodEntry(
          id: 'empty-${day.toIso8601String()}',
          date: day,
          emoji: '—',
          note: '',
          score: 0,
        ),
      );
    });
  }

  int get total => _entries.length;
  int get positives => _entries.where((e) => e.score == 1).length;
  int get negatives => _entries.where((e) => e.score == -1).length;
  int get neutrals => _entries.where((e) => e.score == 0).length;
}
