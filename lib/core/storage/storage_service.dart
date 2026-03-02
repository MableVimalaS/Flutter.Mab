import 'package:hive_flutter/hive_flutter.dart';

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

  // --- Life Clock ---

  int? get birthYear =>
      _settingsBoxInstance.get('birth_year') as int?;

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
    await _settingsBoxInstance.put('total_coins', current + coins);
  }

  // --- Expense Tracking ---

  double get dailyMoneyBudget =>
      (_settingsBoxInstance.get('daily_money_budget', defaultValue: 0.0)
          as num)
          .toDouble();

  Future<void> setDailyMoneyBudget(double budget) async {
    await _settingsBoxInstance.put('daily_money_budget', budget);
  }

  Future<void> clearAllData() async {
    await _activitiesBoxInstance.clear();
  }
}
