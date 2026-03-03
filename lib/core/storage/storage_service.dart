import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../features/activity/data/models/activity_model.dart';

class StorageService {
  static const String _activitiesBox = 'activities';
  static const String _settingsBox = 'settings';

  late Box<ActivityModel> _activitiesBoxInstance;
  late Box<dynamic> _settingsBoxInstance;

  Future<void> init() async {
    _activitiesBoxInstance =
        await Hive.openBox<ActivityModel>(_activitiesBox);
    _settingsBoxInstance = await Hive.openBox<dynamic>(_settingsBox);
  }

  // --- Activities ---

  Box<ActivityModel> get activitiesBox => _activitiesBoxInstance;

  List<ActivityModel> getAllActivities() =>
      _activitiesBoxInstance.values.toList();

  List<ActivityModel> getActivitiesForDate(DateTime date) {
    return _activitiesBoxInstance.values.where((a) {
      return a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day;
    }).toList();
  }

  Future<void> saveActivity(ActivityModel activity) async {
    await _activitiesBoxInstance.put(activity.id, activity);
  }

  Future<void> deleteActivity(String id) async {
    await _activitiesBoxInstance.delete(id);
  }

  // --- Settings ---

  T? getSetting<T>(String key) => _settingsBoxInstance.get(key) as T?;

  Future<void> setSetting<T>(String key, T value) async {
    await _settingsBoxInstance.put(key, value);
  }

  bool get hasCompletedOnboarding =>
      _settingsBoxInstance.get('onboarding_complete', defaultValue: false)
          as bool;

  Future<void> completeOnboarding() async {
    await _settingsBoxInstance.put('onboarding_complete', true);
  }

  String get themeMode =>
      _settingsBoxInstance.get('theme_mode', defaultValue: 'system') as String;

  Future<void> setThemeMode(String mode) async {
    await _settingsBoxInstance.put('theme_mode', mode);
  }

  int get dailyHoursBudget =>
      _settingsBoxInstance.get('daily_hours_budget', defaultValue: 16) as int;

  Future<void> setDailyHoursBudget(int hours) async {
    await _settingsBoxInstance.put('daily_hours_budget', hours);
  }

  // --- Life Clock: Date of Birth ---

  /// Full date of birth. Falls back to old `birth_year` if available.
  DateTime? get dateOfBirth {
    final isoString = _settingsBoxInstance.get('date_of_birth') as String?;
    if (isoString != null) {
      return DateTime.tryParse(isoString);
    }
    // Migration fallback: old birth_year -> Jan 1 of that year
    final oldYear = _settingsBoxInstance.get('birth_year') as int?;
    if (oldYear != null) {
      return DateTime(oldYear);
    }
    return null;
  }

  Future<void> setDateOfBirth(DateTime dob) async {
    await _settingsBoxInstance.put('date_of_birth', dob.toIso8601String());
  }

  /// Legacy getter preserved for backward compatibility.
  int? get birthYear => dateOfBirth?.year;

  Future<void> setBirthYear(int year) async {
    await _settingsBoxInstance.put('birth_year', year);
  }

  // --- Time Coins ---

  int get totalCoins =>
      _settingsBoxInstance.get('total_coins', defaultValue: 0) as int;

  Future<void> setTotalCoins(int coins) async {
    await _settingsBoxInstance.put('total_coins', coins);
  }

  Future<void> addCoins(int coins) async {
    final current = totalCoins;
    final result = (current + coins).clamp(0, 999999999);
    await _settingsBoxInstance.put('total_coins', result);
  }

  // --- Life Penalty ---

  int get lifePenaltyMinutes =>
      _settingsBoxInstance.get('life_penalty_minutes', defaultValue: 0) as int;

  Future<void> setLifePenaltyMinutes(int minutes) async {
    await _settingsBoxInstance.put('life_penalty_minutes', minutes);
  }

  Future<void> addLifePenaltyMinutes(int minutes) async {
    final current = lifePenaltyMinutes;
    await _settingsBoxInstance.put('life_penalty_minutes', current + minutes);
  }

  // --- Expense Tracking ---

  double get dailyMoneyBudget =>
      (_settingsBoxInstance.get('daily_money_budget', defaultValue: 0.0)
          as num)
          .toDouble();

  Future<void> setDailyMoneyBudget(double budget) async {
    await _settingsBoxInstance.put('daily_money_budget', budget);
  }

  // --- Coach Marks ---

  bool get hasShownCoachMarks =>
      _settingsBoxInstance.get('coach_marks_shown', defaultValue: false)
          as bool;

  Future<void> setCoachMarksShown() async {
    await _settingsBoxInstance.put('coach_marks_shown', true);
  }

  Future<void> resetCoachMarks() async {
    await _settingsBoxInstance.put('coach_marks_shown', false);
  }

  Future<void> clearAllData() async {
    await _activitiesBoxInstance.clear();
  }
}
