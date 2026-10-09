import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'application/learning_controller.dart';
import 'data/learning_repository.dart';
import 'data/firebase_services.dart';
import 'data/platform_services.dart';
import 'data/settings_store.dart';
import 'presentation/app.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'application/cubits.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  var cloudReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    cloudReady = true;
  } catch (_) {
    cloudReady = false;
  }
  final firestore = cloudReady ? FirebaseFirestore.instance : null;
  final controller = LearningController(
    repository: OfflineLearningRepository(preferences, firestore: firestore),
    preferences: PreferencesSettingsStore(preferences),
    auth: cloudReady ? FirebaseAuthGateway(FirebaseAuth.instance) : null,
    community: firestore == null ? null : FirebaseCommunityGateway(firestore),
    speech: SpeechService(),
    reminders: ReminderService(),
    homeWidget: ProgressWidgetService(),
  );
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LearningCubit(controller)),
        BlocProvider(create: (_) => SettingsCubit(controller)),
        BlocProvider(create: (_) => AuthCubit(controller.auth)),
      ],
      child: EasyEnglishApp(controller: controller),
    ),
  );
  await controller.initialize();
}
