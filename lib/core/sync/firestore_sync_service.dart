import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/activity/data/models/activity_model.dart';
import '../storage/storage_service.dart';

class FirestoreSyncService {
  FirestoreSyncService(
    this._storage, {
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final StorageService _storage;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  CollectionReference<Map<String, dynamic>>? get _activitiesCol {
    return _userDoc?.collection('activities');
  }

  // --- Full Sync (on login) ---

  Future<void> fullSync() async {
    if (_userDoc == null) return;

    try {
      // Pull cloud settings
      final userSnap = await _userDoc!.get();
      if (userSnap.exists) {
        final data = userSnap.data()!;
        _applyCloudSettings(data);
      }

      // Pull cloud activities
      final activitiesSnap = await _activitiesCol!.get();
      for (final doc in activitiesSnap.docs) {
        final data = doc.data();
        final activity = _activityFromFirestore(doc.id, data);
        await _storage.saveActivity(activity);
      }

      // Push local data to cloud
      await pushSettings();
      await _pushAllActivities();
    } catch (_) {
      // Sync errors are non-fatal — local data is always available
    }
  }

  void _applyCloudSettings(Map<String, dynamic> data) {
    if (data['dateOfBirth'] != null) {
      final dob = DateTime.tryParse(data['dateOfBirth'] as String);
      if (dob != null) _storage.setDateOfBirth(dob);
    }
    if (data['themeMode'] != null) {
      _storage.setThemeMode(data['themeMode'] as String);
    }
    if (data['dailyHoursBudget'] != null) {
      _storage.setDailyHoursBudget(data['dailyHoursBudget'] as int);
    }
    if (data['totalCoins'] != null) {
      _storage.setTotalCoins(data['totalCoins'] as int);
    }
    if (data['lifePenaltyMinutes'] != null) {
      _storage.setLifePenaltyMinutes(data['lifePenaltyMinutes'] as int);
    }
    if (data['dailyMoneyBudget'] != null) {
      _storage.setDailyMoneyBudget((data['dailyMoneyBudget'] as num).toDouble());
    }
    if (data['onboardingComplete'] != null) {
      if (data['onboardingComplete'] as bool) {
        _storage.completeOnboarding();
      }
    }
  }

  // --- Push Settings ---

  Future<void> pushSettings() async {
    if (_userDoc == null) return;

    try {
      final dob = _storage.dateOfBirth;
      await _userDoc!.set({
        'dateOfBirth': dob?.toIso8601String(),
        'themeMode': _storage.themeMode,
        'dailyHoursBudget': _storage.dailyHoursBudget,
        'totalCoins': _storage.totalCoins,
        'lifePenaltyMinutes': _storage.lifePenaltyMinutes,
        'dailyMoneyBudget': _storage.dailyMoneyBudget,
        'onboardingComplete': _storage.hasCompletedOnboarding,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Non-fatal
    }
  }

  // --- Activity Sync ---

  Future<void> pushActivity(ActivityModel activity) async {
    if (_activitiesCol == null) return;

    try {
      await _activitiesCol!.doc(activity.id).set({
        'categoryId': activity.categoryId,
        'durationMinutes': activity.durationMinutes,
        'date': activity.date.toIso8601String(),
        'note': activity.note,
        'expenseAmount': activity.expenseAmount,
        'createdAt': activity.createdAt.toIso8601String(),
      });
    } catch (_) {
      // Non-fatal
    }
  }

  Future<void> deleteActivityRemote(String activityId) async {
    if (_activitiesCol == null) return;

    try {
      await _activitiesCol!.doc(activityId).delete();
    } catch (_) {
      // Non-fatal
    }
  }

  Future<void> _pushAllActivities() async {
    if (_activitiesCol == null) return;

    final activities = _storage.getAllActivities();
    final batch = _firestore.batch();

    for (final activity in activities) {
      final ref = _activitiesCol!.doc(activity.id);
      batch.set(ref, {
        'categoryId': activity.categoryId,
        'durationMinutes': activity.durationMinutes,
        'date': activity.date.toIso8601String(),
        'note': activity.note,
        'expenseAmount': activity.expenseAmount,
        'createdAt': activity.createdAt.toIso8601String(),
      });
    }

    try {
      await batch.commit();
    } catch (_) {
      // Non-fatal
    }
  }

  ActivityModel _activityFromFirestore(String id, Map<String, dynamic> data) {
    return ActivityModel(
      id: id,
      categoryId: data['categoryId'] as String? ?? 'other',
      durationMinutes: data['durationMinutes'] as int? ?? 0,
      date: DateTime.tryParse(data['date'] as String? ?? '') ?? DateTime.now(),
      note: data['note'] as String? ?? '',
      expenseAmount: (data['expenseAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? ''),
    );
  }
}
