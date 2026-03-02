import '../../../../core/storage/storage_service.dart';
import '../models/activity_model.dart';

class ActivityRepositoryImpl {
  const ActivityRepositoryImpl(this._storage);

  final StorageService _storage;

  List<ActivityModel> getAllActivities() => _storage.getAllActivities();

  List<ActivityModel> getActivitiesForDate(DateTime date) =>
      _storage.getActivitiesForDate(date);

  List<ActivityModel> getActivitiesForDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _storage.getAllActivities().where((a) {
      return !a.date.isBefore(start) && a.date.isBefore(end);
    }).toList();
  }

  Future<void> saveActivity(ActivityModel activity) =>
      _storage.saveActivity(activity);

  Future<void> deleteActivity(String id) => _storage.deleteActivity(id);

  int get dailyHoursBudget => _storage.dailyHoursBudget;

  int getTotalMinutesForDate(DateTime date) {
    final activities = getActivitiesForDate(date);
    return activities.fold<int>(0, (sum, a) => sum + a.durationMinutes);
  }

  Map<String, int> getCategoryMinutesForDate(DateTime date) {
    final activities = getActivitiesForDate(date);
    final map = <String, int>{};
    for (final a in activities) {
      map[a.categoryId] = (map[a.categoryId] ?? 0) + a.durationMinutes;
    }
    return map;
  }

  int getStreakDays() {
    var streak = 0;
    var date = DateTime.now();

    while (true) {
      final activities = getActivitiesForDate(date);
      if (activities.isEmpty) break;
      streak++;
      date = date.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Map<String, int> getWeeklyCategoryTotals() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));

    final activities = getActivitiesForDateRange(start, end);
    final map = <String, int>{};
    for (final a in activities) {
      map[a.categoryId] = (map[a.categoryId] ?? 0) + a.durationMinutes;
    }
    return map;
  }

  List<MapEntry<DateTime, int>> getDailyTotalsForWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (i) {
      final date = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + i,
      );
      return MapEntry(date, getTotalMinutesForDate(date));
    });
  }
}
