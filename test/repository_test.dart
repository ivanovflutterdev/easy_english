import 'package:easy_english/data/learning_repository.dart';
import 'package:easy_english/domain/learning.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'concurrent local and cloud saves merge events and isolate users',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repository = OfflineLearningRepository(
        await SharedPreferences.getInstance(),
      );
      final now = DateTime(2026, 10, 7);
      ReviewEvent event(String id) => ReviewEvent(
        id: id,
        wordId: 'learn',
        at: now,
        recall: Recall.good,
        progress: CardProgress(due: now),
      );
      await Future.wait([
        repository.saveEvents('alice', [event('local')]),
        repository.saveEvents('alice', [event('remote')]),
        repository.saveEvents('bob', [event('separate')]),
      ]);
      expect((await repository.loadEvents('alice')).map((e) => e.id).toSet(), {
        'local',
        'remote',
      });
      expect((await repository.loadEvents('bob')).single.id, 'separate');
    },
  );
  test(
    'Oxford catalogue is unique and custom translations survive reload',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repository = OfflineLearningRepository(
        await SharedPreferences.getInstance(),
      );
      final words = await repository.loadWords();
      expect(words.length, 4957);
      expect(words.map((w) => w.id).toSet().length, words.length);
      expect(words.where((w) => w.translation.isNotEmpty).length, 32);
      final empty = words.firstWhere((w) => w.translation.isEmpty);
      await repository.saveTranslation(empty.id, 'Мой перевод');
      expect(
        (await repository.loadWords())
            .firstWhere((w) => w.id == empty.id)
            .translation,
        'Мой перевод',
      );
    },
  );
}
