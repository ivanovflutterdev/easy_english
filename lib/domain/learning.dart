import 'dart:math' as math;

class VocabularyWord {
  const VocabularyWord({
    required this.id,
    required this.word,
    required this.translation,
    required this.example,
    required this.level,
    this.phonetic = '',
    this.advanced = false,
  });
  final String id, word, translation, example, level, phonetic;
  final bool advanced;
  factory VocabularyWord.fromJson(Map<String, dynamic> json) => VocabularyWord(
    id: json['id'] as String,
    word: json['word'] as String,
    translation: json['translation'] as String,
    example: json['example'] as String,
    level: json['level'] as String,
    phonetic: json['phonetic'] as String? ?? '',
    advanced: json['advanced'] == true,
  );
}

enum Recall { again, hard, good, easy }

class CardProgress {
  const CardProgress({
    required this.due,
    this.interval = 0,
    this.ease = 2.5,
    this.repetitions = 0,
  });
  final DateTime due;
  final int interval, repetitions;
  final double ease;
  Map<String, dynamic> toJson() => {
    'due': due.toUtc().toIso8601String(),
    'interval': interval,
    'ease': ease,
    'repetitions': repetitions,
  };
  factory CardProgress.fromJson(Map<String, dynamic> json) => CardProgress(
    due: DateTime.parse(json['due'] as String),
    interval: (json['interval'] as num).toInt(),
    ease: (json['ease'] as num).toDouble(),
    repetitions: (json['repetitions'] as num).toInt(),
  );
}

/// SM-2 inspired scheduling; a failed retrieval returns the card in one minute.
class ReviewScheduler {
  const ReviewScheduler();
  CardProgress review(CardProgress? old, Recall recall, DateTime now) {
    final previous = old ?? CardProgress(due: now);
    if (recall == Recall.again) {
      return CardProgress(
        due: now.add(const Duration(minutes: 1)),
        ease: math.max(1.3, previous.ease - .2),
      );
    }
    final ease = math.max(
      1.3,
      previous.ease +
          (recall == Recall.hard
              ? -.15
              : recall == Recall.easy
              ? .15
              : 0),
    );
    final int days;
    if (previous.repetitions == 0) {
      days = recall == Recall.easy ? 4 : 1;
    } else if (previous.repetitions == 1) {
      days = recall == Recall.hard
          ? 3
          : recall == Recall.easy
          ? 8
          : 6;
    } else {
      days = math.max(
        previous.interval + 1,
        (previous.interval *
                (recall == Recall.hard
                    ? 1.2
                    : ease * (recall == Recall.easy ? 1.3 : 1)))
            .round(),
      );
    }
    return CardProgress(
      due: now.add(Duration(days: days)),
      interval: days,
      ease: ease,
      repetitions: previous.repetitions + 1,
    );
  }
}

String dayKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class ReviewEvent {
  const ReviewEvent({
    required this.id,
    required this.wordId,
    required this.at,
    required this.recall,
    required this.progress,
  });
  final String id, wordId;
  final DateTime at;
  final Recall recall;
  final CardProgress progress;
  Map<String, dynamic> toJson() => {
    'id': id,
    'wordId': wordId,
    'at': at.toUtc().toIso8601String(),
    'day': dayKey(at),
    'recall': recall.index,
    'progress': progress.toJson(),
  };
  factory ReviewEvent.fromJson(Map<String, dynamic> json) => ReviewEvent(
    id: json['id'] as String,
    wordId: json['wordId'] as String,
    at: DateTime.parse(json['at'] as String).toLocal(),
    recall: Recall.values[(json['recall'] as num).toInt()],
    progress: CardProgress.fromJson(
      Map<String, dynamic>.from(json['progress'] as Map),
    ),
  );
}

abstract class LearningRepository {
  Future<void> saveTranslation(String wordId, String translation);
  Future<List<VocabularyWord>> loadWords();
  Future<List<ReviewEvent>> loadEvents(String owner);
  Future<void> saveEvents(String owner, List<ReviewEvent> events);
  Stream<List<ReviewEvent>> watchRemote(String uid);
  Future<void> upload(String uid, List<ReviewEvent> events);
}

int currentStreak(Iterable<ReviewEvent> events, DateTime now) {
  final days = events.map((e) => dayKey(e.at)).toSet();
  var day = DateTime(now.year, now.month, now.day);
  if (!days.contains(dayKey(day))) {
    day = DateTime(day.year, day.month, day.day - 1);
  }
  var count = 0;
  while (days.contains(dayKey(day))) {
    count++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return count;
}
