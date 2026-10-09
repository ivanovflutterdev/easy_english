import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/learning.dart';
import '../domain/services.dart';
import 'learning_controller.dart';

/// A small immutable projection used by widgets that only need learning data.
class LearningState {
  const LearningState({
    this.ready = false,
    this.saving = false,
    this.error,
    this.syncStatus = '',
    this.today = 0,
    this.streak = 0,
    this.xp = 0,
    this.due = 0,
    this.learned = 0,
  });
  final bool ready, saving;
  final String? error;
  final String syncStatus;
  final int today, streak, xp, due, learned;
  factory LearningState.from(LearningController c) => LearningState(
    ready: c.ready,
    saving: c.saving,
    error: c.error,
    syncStatus: c.syncStatus,
    today: c.today,
    streak: c.streak,
    xp: c.xp,
    due: c.due,
    learned: c.learned,
  );
}

class LearningCubit extends Cubit<LearningState> {
  LearningCubit(this.controller) : super(LearningState.from(controller)) {
    controller.addListener(_onChanged);
  }
  final LearningController controller;
  void _onChanged() => emit(LearningState.from(controller));
  Future<void> initialize() => controller.initialize();
  Future<void> answer(VocabularyWord word, Recall recall) =>
      controller.answer(word, recall);
  @override
  Future<void> close() {
    controller.removeListener(_onChanged);
    return super.close();
  }
}

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.locale,
    required this.colorIndex,
    required this.textScale,
    required this.reduceGlass,
  });
  final ThemeMode themeMode;
  final Locale locale;
  final int colorIndex;
  final double textScale;
  final bool reduceGlass;
  factory SettingsState.from(LearningController c) => SettingsState(
    themeMode: c.themeMode,
    locale: c.locale,
    colorIndex: c.colorIndex,
    textScale: c.textScale,
    reduceGlass: c.reduceGlass,
  );
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this.controller) : super(SettingsState.from(controller)) {
    controller.addListener(_onChanged);
  }
  final LearningController controller;
  void _onChanged() => emit(SettingsState.from(controller));
  Future<void> set(String key, Object value) => controller.setting(key, value);
  Future<void> toggleLanguage() =>
      set('language', state.locale.languageCode == 'uk' ? 'ru' : 'uk');
  @override
  Future<void> close() {
    controller.removeListener(_onChanged);
    return super.close();
  }
}

class AuthState {
  const AuthState({this.user, this.loading = false, this.error});
  final Learner? user;
  final bool loading;
  final String? error;
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.gateway) : super(AuthState(user: gateway?.currentUser)) {
    _subscription = gateway?.authStateChanges().listen(
      (user) => emit(AuthState(user: user)),
    );
  }
  final AuthGateway? gateway;
  StreamSubscription<Learner?>? _subscription;
  Future<void> signOut() async {
    await gateway?.signOut();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
