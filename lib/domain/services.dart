class Learner {
  const Learner(this.uid, this.email);
  final String uid;
  final String? email;
}

class AuthFailure implements Exception {
  const AuthFailure(this.code);
  final String code;
}

abstract class AuthGateway {
  Learner? get currentUser;
  Stream<Learner?> authStateChanges();
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> signOut();
}

class RankingEntry {
  const RankingEntry(this.uid, this.name, this.xp);
  final String uid, name;
  final int xp;
}

abstract class CommunityGateway {
  Stream<List<RankingEntry>> watchRanking();
  Future<void> enablePush(String uid);
  Future<void> disablePush(String uid);
  Future<void> dispose();
}

abstract class SettingsStore {
  int? getInt(String key);
  double? getDouble(String key);
  bool? getBool(String key);
  String? getString(String key);
  Future<bool> setInt(String key, int value);
  Future<bool> setDouble(String key, double value);
  Future<bool> setBool(String key, bool value);
  Future<bool> setString(String key, String value);
}

abstract class SpeechGateway {
  Future<void> speak(String text, {String accent = 'en-GB', double rate = .45});
  Future<void> stop();
}

abstract class ReminderGateway {
  Future<bool> schedule(int hour, int minute);
  Future<void> cancel();
}

abstract class WidgetGateway {
  Future<void> update({
    required int today,
    required int goal,
    required int streak,
    required int due,
  });
}
