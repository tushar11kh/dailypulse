// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageService {
  static const _key = 'dailypulse_entries';
  final _firestore = FirebaseFirestore.instance;

  // ---------- LOCAL ----------
  Future<void> saveList(List<String> encodedList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, encodedList);
  }

  Future<List<String>> loadList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // ---------- FIRESTORE ----------
  Future<void> saveListToFirestore(String uid, List<String> encodedList) async {
    final moodsRef = _firestore.collection('users').doc(uid).collection('moods');
    final batch = _firestore.batch();

    // clear old entries and re-add (simpler sync logic)
    final old = await moodsRef.get();
    for (final doc in old.docs) {
      batch.delete(doc.reference);
    }

    for (final e in encodedList) {
      batch.set(moodsRef.doc(), {'encoded': e});
    }

    await batch.commit();
  }

  Future<List<String>> loadListFromFirestore(String uid) async {
    final moodsRef = _firestore.collection('users').doc(uid).collection('moods');
    final snapshot = await moodsRef.get();
    return snapshot.docs.map((d) => d['encoded'] as String).toList();
  }
}
