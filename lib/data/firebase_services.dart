import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../domain/services.dart';

class FirebaseAuthGateway implements AuthGateway {
  FirebaseAuthGateway(this.auth);
  final FirebaseAuth auth;
  Learner? _learner(User? user) =>
      user == null ? null : Learner(user.uid, user.email);
  @override
  Learner? get currentUser => _learner(auth.currentUser);
  @override
  Stream<Learner?> authStateChanges() => auth.authStateChanges().map(_learner);
  Future<void> _call(Future<Object?> Function() operation) async {
    try {
      await operation();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(error.code);
    }
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) => _call(
    () => auth.signInWithEmailAndPassword(email: email, password: password),
  );
  @override
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) => _call(
    () => auth.createUserWithEmailAndPassword(email: email, password: password),
  );
  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _call(() => auth.sendPasswordResetEmail(email: email));
  @override
  Future<void> signOut() => _call(auth.signOut);
}

class FirebaseCommunityGateway implements CommunityGateway {
  FirebaseCommunityGateway(this.firestore);
  final FirebaseFirestore firestore;
  StreamSubscription<String>? _refresh;
  @override
  Stream<List<RankingEntry>> watchRanking() => firestore
      .collection('leaderboard')
      .orderBy('xp', descending: true)
      .limit(30)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => RankingEntry(
                doc.id,
                doc.data()['name'] as String? ?? 'Ученик',
                (doc.data()['xp'] as num? ?? 0).toInt(),
              ),
            )
            .toList(),
      );
  Future<void> _save(String uid, String token) => firestore
      .collection('users')
      .doc(uid)
      .collection('devices')
      .doc(token)
      .set({'token': token, 'updatedAt': FieldValue.serverTimestamp()});
  @override
  Future<void> enablePush(String uid) async {
    final messaging = FirebaseMessaging.instance;
    final permission = await messaging.requestPermission();
    if (permission.authorizationStatus != AuthorizationStatus.authorized &&
        permission.authorizationStatus != AuthorizationStatus.provisional) {
      throw StateError('Notification permission denied');
    }
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    final token = await messaging.getToken();
    if (token == null) throw StateError('Push token not available');
    await _save(uid, token).timeout(const Duration(seconds: 15));
    await _refresh?.cancel();
    _refresh = FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      unawaited(_save(uid, token).catchError((Object _) {}));
    });
  }

  @override
  Future<void> disablePush(String uid) async {
    await _refresh?.cancel();
    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();
    // Invalidate locally before deleting the server registration, including offline sign-out.
    await messaging.deleteToken();
    if (token != null) {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('devices')
          .doc(token)
          .delete()
          .timeout(const Duration(seconds: 10));
    }
  }

  @override
  Future<void> dispose() async {
    await _refresh?.cancel();
  }
}
