import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../domain/services.dart';
import '../domain/learning.dart';

class LearningController extends ChangeNotifier {
  LearningController({
    required this.repository,
    required this.preferences,
    this.auth,
    this.community,
    required this.speech,
    required this.reminders,
    required this.homeWidget,
  });
  final LearningRepository repository;
  final SettingsStore preferences;
  final AuthGateway? auth;
  final CommunityGateway? community;
  final scheduler = const ReviewScheduler();
  final SpeechGateway speech;
  final ReminderGateway reminders;
  final WidgetGateway homeWidget;
  List<VocabularyWord> words = [];
  List<ReviewEvent> events = [];
  Map<String, CardProgress> progress = {};
  bool ready = false, saving = false;
  String? error;
  String syncStatus = 'Прогресс на устройстве';
  String owner = 'guest';
  int _generation = 0;
  StreamSubscription<Learner?>? _authSubscription;
  StreamSubscription<List<ReviewEvent>>? _remoteSubscription;
  Timer? _timer;
  ThemeMode get themeMode => ThemeMode.values[preferences.getInt('theme') ?? 0];
  Locale get locale => Locale(preferences.getString('language') ?? 'ru');
  int get goal => preferences.getInt('goal') ?? 10;
  String get accent => preferences.getString('accent') ?? 'en-GB';
  double get speechRate => preferences.getDouble('rate') ?? .45;
  double get textScale => preferences.getDouble('textScale') ?? 1;
  int get colorIndex => preferences.getInt('color') ?? 0;
  bool get reduceGlass => preferences.getBool('reduceGlass') ?? false;
  bool get reminderEnabled => preferences.getBool('reminder') ?? false;
  bool get pushEnabled => preferences.getBool('push_$owner') ?? false;
  int get reminderHour => preferences.getInt('hour') ?? 19;
  int get reminderMinute => preferences.getInt('minute') ?? 0;
  Learner? get user => auth?.currentUser;
  int get today =>
      events.where((e) => dayKey(e.at) == dayKey(DateTime.now())).length;
  int get streak => currentStreak(events, DateTime.now());
  int get xp =>
      events.fold(0, (total, e) => total + (e.recall == Recall.again ? 2 : 10));
  int get learned => progress.values.where((p) => p.interval >= 21).length;
  int get due =>
      progress.values.where((p) => !p.due.isAfter(DateTime.now())).length;
  List<VocabularyWord> queue({String deck = 'all'}) =>
      words.where((w) {
        if (w.translation.isEmpty) return false;
        if (deck == 'core' && w.advanced || deck == 'advanced' && !w.advanced) {
          return false;
        }
        return progress[w.id] == null ||
            !progress[w.id]!.due.isAfter(DateTime.now());
      }).toList()..sort((a, b) {
        final pa = progress[a.id], pb = progress[b.id];
        if (pa == null && pb == null) return 0;
        if (pa == null) return 1;
        if (pb == null) return -1;
        return pa.due.compareTo(pb.due);
      });
  Future<void> initialize() async {
    try {
      words = await repository.loadWords();
      await _switchOwner(user?.uid ?? 'guest');
      _authSubscription = auth?.authStateChanges().listen((user) {
        if ((user?.uid ?? 'guest') != owner) {
          unawaited(_switchOwner(user?.uid ?? 'guest'));
        }
      });
      _timer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => notifyListeners(),
      );
    } catch (_) {
      error = 'Не удалось загрузить данные. Перезапустите приложение.';
    }
    ready = true;
    notifyListeners();
  }

  Future<void> saveTranslation(String id, String translation) async {
    await repository.saveTranslation(id, translation.trim());
    words = await repository.loadWords();
    notifyListeners();
  }

  Future<void> _switchOwner(String next) async {
    final generation = ++_generation;
    await _remoteSubscription?.cancel();
    await community?.dispose();
    owner = next;
    events = [];
    progress = {};
    notifyListeners();
    final local = await repository.loadEvents(next);
    if (generation != _generation) return;
    events = local;
    _rebuild();
    syncStatus = next == 'guest'
        ? 'Прогресс на устройстве'
        : 'Подключение к облаку…';
    if (next != 'guest') {
      _remoteSubscription = repository
          .watchRemote(next)
          .listen(
            (remote) async {
              if (generation != _generation) return;
              final merged = {
                for (final e in events) e.id: e,
                for (final e in remote) e.id: e,
              };
              events = merged.values.toList()
                ..sort((a, b) => a.at.compareTo(b.at));
              _rebuild();
              syncStatus = 'Синхронизация подключена';
              notifyListeners();
              try {
                await repository.saveEvents(next, events);
              } catch (_) {
                report('Не удалось сохранить облачные данные на устройстве.');
              }
            },
            onError: (Object _) {
              if (generation == _generation) {
                syncStatus = 'Облако недоступно · данные сохранены локально';
                notifyListeners();
              }
            },
          );
      if (local.isNotEmpty) unawaited(_upload(next, local, generation));
    }
    notifyListeners();
    unawaited(_updateWidget());
  }

  void _rebuild() {
    progress = {};
    final sorted = [...events]
      ..sort((a, b) {
        final time = a.at.compareTo(b.at);
        return time == 0 ? a.id.compareTo(b.id) : time;
      });
    for (final e in sorted) {
      progress[e.wordId] = scheduler.review(progress[e.wordId], e.recall, e.at);
    }
  }

  Future<void> answer(VocabularyWord word, Recall recall) async {
    if (saving) return;
    saving = true;
    notifyListeners();
    final generation = _generation, currentOwner = owner;
    try {
      final now = DateTime.now();
      final id =
          '${now.microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}';
      final event = ReviewEvent(
        id: id,
        wordId: word.id,
        at: now,
        recall: recall,
        progress: scheduler.review(progress[word.id], recall, now),
      );
      final updated = [...events, event];
      await repository.saveEvents(currentOwner, updated);
      if (generation != _generation) return;
      events = {
        for (final e in events) e.id: e,
        for (final e in updated) e.id: e,
      }.values.toList();
      _rebuild();
      if (currentOwner != 'guest') {
        unawaited(_upload(currentOwner, [event], generation));
      }
      unawaited(_updateWidget());
    } catch (_) {
      report('Ответ не сохранён. Попробуйте ещё раз.');
      rethrow;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> _upload(
    String uid,
    List<ReviewEvent> pending,
    int generation,
  ) async {
    if (generation == _generation) {
      syncStatus = 'Отправка прогресса…';
      notifyListeners();
    }
    try {
      await repository.upload(uid, pending);
      if (generation == _generation) syncStatus = 'Синхронизировано';
    } catch (_) {
      if (generation == _generation) {
        syncStatus = 'Офлайн · отправим при подключении';
      }
    }
    if (generation == _generation) notifyListeners();
  }

  Future<void> _updateWidget() async {
    try {
      await homeWidget.update(
        today: today,
        goal: goal,
        streak: streak,
        due: due,
      );
    } catch (_) {
      /* OS widget is optional. */
    }
  }

  void report(String message) {
    error = message;
    notifyListeners();
  }

  void clearError() {
    error = null;
  }

  Future<void> setting(String key, Object value) async {
    if (value is int) {
      await preferences.setInt(key, value);
    }
    if (value is double) {
      await preferences.setDouble(key, value);
    }
    if (value is bool) {
      await preferences.setBool(key, value);
    }
    if (value is String) {
      await preferences.setString(key, value);
    }
    notifyListeners();
    if (key == 'goal') unawaited(_updateWidget());
  }

  Future<void> speak(String word) async {
    try {
      await speech.speak(word, accent: accent, rate: speechRate);
    } catch (_) {
      report('Озвучка недоступна. Установите английский голос на устройстве.');
    }
  }

  Future<void> setReminder(bool enabled, {TimeOfDay? time}) async {
    try {
      final hour = time?.hour ?? reminderHour,
          minute = time?.minute ?? reminderMinute;
      if (enabled && !await reminders.schedule(hour, minute)) {
        report('Разрешите уведомления в настройках устройства.');
        return;
      }
      if (!enabled) await reminders.cancel();
      await setting('hour', hour);
      await setting('minute', minute);
      await setting('reminder', enabled);
    } catch (_) {
      report('Не удалось настроить напоминание на этом устройстве.');
    }
  }

  Future<void> setPush(bool enabled) async {
    final uid = user?.uid;
    if (uid == null || community == null) {
      report('Для push-уведомлений войдите в аккаунт.');
      return;
    }
    try {
      if (enabled) {
        await community!.enablePush(uid);
      } else {
        await community!.disablePush(uid);
      }
      await setting('push_$uid', enabled);
    } catch (_) {
      report(
        'Push пока недоступен. Проверьте разрешение уведомлений и конфигурацию Firebase/APNs.',
      );
    }
  }

  Future<void> signOut() async {
    if (pushEnabled) await setPush(false);
    await auth?.signOut();
  }

  @override
  void dispose() {
    _generation++;
    _timer?.cancel();
    _authSubscription?.cancel();
    _remoteSubscription?.cancel();
    community?.dispose();
    unawaited(speech.stop().catchError((Object _) {}));
    super.dispose();
  }
}
