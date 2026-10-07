import 'package:easy_english/domain/learning.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scheduler = ReviewScheduler();
  final now = DateTime(2026, 10, 7, 12);
  test('successful recall grows the interval from 1 to 6 to 15 days', () {
    final first = scheduler.review(null, Recall.good, now);
    final second = scheduler.review(first, Recall.good, first.due);
    final third = scheduler.review(second, Recall.good, second.due);
    expect([first.interval, second.interval, third.interval], [1, 6, 15]);
  });
  test('lapse resets repetitions and returns the word in one minute', () {
    final old = CardProgress(due: now, interval: 60, repetitions: 8, ease: 1.3);
    final next = scheduler.review(old, Recall.again, now);
    expect(next.repetitions, 0);
    expect(next.ease, 1.3);
    expect(next.due, now.add(const Duration(minutes: 1)));
  });
  test('easy recall schedules longer than hard recall', () {
    final old = CardProgress(due: now, interval: 10, repetitions: 4);
    expect(
      scheduler.review(old, Recall.easy, now).interval,
      greaterThan(scheduler.review(old, Recall.hard, now).interval),
    );
  });
  ReviewEvent event(DateTime date) => ReviewEvent(
    id: date.toIso8601String(),
    wordId: 'learn',
    at: date,
    recall: Recall.good,
    progress: CardProgress(due: date),
  );
  test('streak survives until the end of the next day and then resets', () {
    final events = [event(DateTime(2026, 10, 5)), event(DateTime(2026, 10, 6))];
    expect(currentStreak(events, now), 2);
    expect(currentStreak(events, DateTime(2026, 10, 8)), 0);
    events.add(event(now));
    events.add(event(now.add(const Duration(minutes: 1))));
    expect(currentStreak(events, now), 3);
  });
  test('events retain schedule and timestamp through JSON', () {
    final original = event(now);
    final restored = ReviewEvent.fromJson(original.toJson());
    expect(restored.at, original.at);
    expect(restored.progress.toJson(), original.progress.toJson());
    expect(restored.recall, original.recall);
  });
}
