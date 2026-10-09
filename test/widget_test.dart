import 'package:easy_english/application/learning_controller.dart';
import 'package:easy_english/data/learning_repository.dart';
import 'package:easy_english/data/settings_store.dart';
import 'package:easy_english/data/platform_services.dart';
import 'package:easy_english/presentation/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<LearningController> setup() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final c = LearningController(
      repository: OfflineLearningRepository(preferences),
      preferences: PreferencesSettingsStore(preferences),
      speech: SpeechService(),
      reminders: ReminderService(),
      homeWidget: ProgressWidgetService(),
    );
    await c.initialize();
    return c;
  }

  testWidgets(
    'mobile review reveals translation, saves answer and restores progress',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = (await tester.runAsync(setup))!;
      await tester.pumpWidget(EasyEnglishApp(controller: c));
      await tester.pumpAndSettle();
      expect(find.text('Начать занятие'), findsOneWidget);
      await tester.ensureVisible(find.text('Начать занятие'));
      await tester.tap(find.text('Начать занятие'));
      await tester.pumpAndSettle();
      expect(find.text('discover'), findsOneWidget);
      expect(find.text('открывать, обнаруживать'), findsNothing);
      await tester.tap(find.text('Показать перевод'));
      await tester.pumpAndSettle();
    expect(find.text('відкривати, виявляти'), findsOneWidget);
      await tester.ensureVisible(find.text('Помню'));
      await tester.tap(find.text('Помню'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      expect(c.events, hasLength(1));
      expect(c.today, 1);
      expect(c.xp, 10);
      final restored = await c.repository.loadEvents('guest');
      expect(restored.single.wordId, 'discover');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      c.dispose();
      await tester.pump();
    },
  );
  testWidgets(
    'desktop navigation, dark theme, and large text do not overflow',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = (await tester.runAsync(setup))!;
      await c.setting('theme', 2);
      await c.setting('textScale', 1.3);
      await tester.pumpWidget(EasyEnglishApp(controller: c));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final label in ['Словарь', 'Прогресс', 'Достижения', 'Настройки']) {
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: label);
      }
      await tester.pumpWidget(const SizedBox());
      c.dispose();
      await tester.pump();
    },
  );
}
