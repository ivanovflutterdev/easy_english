import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/learning.dart';

class OfflineLearningRepository implements LearningRepository {
  OfflineLearningRepository(this.preferences, {this.firestore});
  final SharedPreferences preferences;
  final FirebaseFirestore? firestore;
  Future<void>? _writeQueue;
  @override
  Future<List<VocabularyWord>> loadWords() async {
    final json =
        jsonDecode(await rootBundle.loadString('assets/words.json')) as List;
    final examples = json
        .map(
          (row) =>
              VocabularyWord.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
    final catalog =
        jsonDecode(await rootBundle.loadString('assets/oxford_catalog.json'))
            as List;
    final exampleMap = {for (final word in examples) word.id: word};
    final words = catalog.map((row) {
      final item = Map<String, dynamic>.from(row as Map);
      final sample = exampleMap[item['id']];
      item['translation'] =
          preferences.getString('translation_${item['id']}') ??
          sample?.translation ??
          '';
      item['example'] = sample?.example ?? '';
      item['phonetic'] = sample?.phonetic ?? '';
      return VocabularyWord.fromJson(item);
    }).toList();
    // Keep the introductory lesson first; the full catalogue follows alphabetically.
    final order = {for (var i = 0; i < examples.length; i++) examples[i].id: i};
    words.sort((a, b) {
      final comparison = (order[a.id] ?? 999).compareTo(order[b.id] ?? 999);
      return comparison == 0 ? a.word.compareTo(b.word) : comparison;
    });
    return words;
  }

  @override
  Future<void> saveTranslation(String wordId, String translation) async {
    if (!await preferences.setString('translation_$wordId', translation)) {
      throw StateError('Cannot save translation');
    }
  }

  @override
  Future<List<ReviewEvent>> loadEvents(String owner) async {
    final raw = preferences.getString('events_$owner');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => ReviewEvent.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> saveEvents(String owner, List<ReviewEvent> events) {
    final operation = (_writeQueue ?? Future<void>.value()).then((_) async {
      final existing = await loadEvents(owner);
      final merged = {
        for (final e in existing) e.id: e,
        for (final e in events) e.id: e,
      };
      if (!await preferences.setString(
        'events_$owner',
        jsonEncode(merged.values.map((e) => e.toJson()).toList()),
      )) {
        throw StateError('Не удалось сохранить прогресс на устройстве.');
      }
    });
    _writeQueue = operation.catchError((Object _) {});
    return operation;
  }

  @override
  Stream<List<ReviewEvent>> watchRemote(String uid) => firestore!
      .collection('users')
      .doc(uid)
      .collection('reviews')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => ReviewEvent.fromJson(doc.data()))
            .toList(),
      );
  @override
  Future<void> upload(String uid, List<ReviewEvent> events) async {
    // Immutable event IDs make retries idempotent and retain reviews from both devices.
    for (var start = 0; start < events.length; start += 400) {
      final batch = firestore!.batch();
      for (final event in events.skip(start).take(400)) {
        batch.set(
          firestore!
              .collection('users')
              .doc(uid)
              .collection('reviews')
              .doc(event.id),
          event.toJson(),
        );
      }
      await batch.commit();
    }
  }
}
