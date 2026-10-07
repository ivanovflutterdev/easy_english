import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:home_widget/home_widget.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../domain/services.dart';

class SpeechService implements SpeechGateway {
  final FlutterTts _tts = FlutterTts();
  @override
  Future<void> speak(
    String text, {
    String accent = 'en-GB',
    double rate = .45,
  }) async {
    await _tts.stop();
    await _tts.setLanguage(accent);
    await _tts.setSpeechRate(rate);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}

class ReminderService implements ReminderGateway {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  Future<void> initialize() async {
    if (_initialized || !supported) return;
    tz_data.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> schedule(int hour, int minute) async {
    if (!supported) return false;
    await initialize();
    final granted = defaultTargetPlatform == TargetPlatform.android
        ? await _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission()
        : await _notifications
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true);
    if (granted != true) return false;
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!next.isAfter(now)) {
      next = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      );
    }
    await _notifications.zonedSchedule(
      id: 1,
      title: 'Время для английского ✨',
      body: 'Несколько карточек сегодня — уверенный английский завтра.',
      scheduledDate: next,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_review',
          'Ежедневные занятия',
          channelDescription: 'Напоминания о повторении слов',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    return true;
  }

  @override
  Future<void> cancel() async {
    if (supported) {
      await initialize();
      await _notifications.cancel(id: 1);
    }
  }
}

class ProgressWidgetService implements WidgetGateway {
  @override
  Future<void> update({
    required int today,
    required int goal,
    required int streak,
    required int due,
  }) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await HomeWidget.setAppGroupId('group.com.example.easyEnglish');
    }
    await HomeWidget.saveWidgetData('today', today);
    await HomeWidget.saveWidgetData('goal', goal);
    await HomeWidget.saveWidgetData('streak', streak);
    await HomeWidget.saveWidgetData('due', due);
    await HomeWidget.saveWidgetData(
      'updatedDay',
      DateTime.now().toIso8601String().substring(0, 10),
    );
    await HomeWidget.updateWidget(
      androidName: 'ProgressWidgetProvider',
      iOSName: 'EasyEnglishWidget',
    );
  }
}
