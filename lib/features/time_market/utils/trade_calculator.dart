import '../../../core/constants/app_constants.dart';
import '../../../core/constants/rewards_config.dart';
import '../../activity/data/models/activity_model.dart';

class TradeResult {
  const TradeResult({
    required this.categoryId,
    required this.durationMinutes,
    required this.roi,
    required this.reward,
    required this.coinsEarned,
    required this.tradeLabel,
    this.expenseAmount = 0.0,
    this.isBadHabit = false,
    this.lifePenaltyMinutes = 0,
  });

  final String categoryId;
  final int durationMinutes;
  final int roi;
  final String reward;
  final int coinsEarned;
  final String tradeLabel;
  final double expenseAmount;
  final bool isBadHabit;
  final int lifePenaltyMinutes;

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }
}

class TradeSuggestionItem {
  const TradeSuggestionItem({
    required this.fromCategoryId,
    required this.toCategoryIds,
    required this.fromMinutes,
    required this.message,
  });

  final String fromCategoryId;
  final List<String> toCategoryIds;
  final int fromMinutes;
  final String message;
}

class TradeCalculator {
  TradeCalculator._();

  static int calculateCoins(String categoryId, int durationMinutes) {
    return RewardsConfig.calculateCoins(categoryId, durationMinutes);
  }

  static int getROI(String categoryId) {
    return RewardsConfig.roi[categoryId] ?? 2;
  }

  static String getReward(String categoryId) {
    return RewardsConfig.rewards[categoryId] ?? 'Varies';
  }

  static TradeResult evaluateTrade(ActivityModel activity) {
    final roi = getROI(activity.categoryId);
    final reward = getReward(activity.categoryId);
    final coins = calculateCoins(activity.categoryId, activity.durationMinutes);
    final label = RewardsConfig.tradeLabel(roi);
    final badHabit = RewardsConfig.isBadHabit(activity.categoryId);

    int lifePenalty = 0;
    if (badHabit) {
      final sessions = (activity.durationMinutes / 30).ceil();
      final penaltyPerSession =
          RewardsConfig.badHabitPenaltyMinutes[activity.categoryId] ?? 0;
      lifePenalty = sessions * penaltyPerSession;
    }

    return TradeResult(
      categoryId: activity.categoryId,
      durationMinutes: activity.durationMinutes,
      roi: roi,
      reward: reward,
      coinsEarned: coins,
      tradeLabel: label,
      expenseAmount: activity.expenseAmount,
      isBadHabit: badHabit,
      lifePenaltyMinutes: lifePenalty,
    );
  }

  static List<TradeSuggestionItem> generateSuggestions(
    Map<String, int> categoryMinutes,
  ) {
    final suggestions = <TradeSuggestionItem>[];

    // Flag bad habits first with strong warnings
    for (final entry in categoryMinutes.entries) {
      if (RewardsConfig.isBadHabit(entry.key)) {
        final cat = DefaultCategories.getById(entry.key);
        final penalty =
            RewardsConfig.badHabitPenaltyMinutes[entry.key] ?? 0;
        final sessions = (entry.value / 30).ceil();
        final totalPenalty = sessions * penalty;
        suggestions.add(TradeSuggestionItem(
          fromCategoryId: entry.key,
          toCategoryIds: const ['exercise', 'selfcare'],
          fromMinutes: entry.value,
          message:
              '${cat.name} cost you $totalPenalty min of life! Replace with exercise or self-care',
        ));
      }
    }

    // Find low-ROI categories with significant time
    for (final entry in categoryMinutes.entries) {
      if (RewardsConfig.isBadHabit(entry.key)) continue;
      final roi = getROI(entry.key);
      if (roi <= 1 && entry.value >= 30) {
        final cat = DefaultCategories.getById(entry.key);
        final mins = entry.value;
        final hours = mins ~/ 60;
        final remMins = mins % 60;
        final timeStr = hours > 0
            ? (remMins > 0 ? '${hours}h ${remMins}m' : '${hours}h')
            : '${mins}m';

        suggestions.add(TradeSuggestionItem(
          fromCategoryId: entry.key,
          toCategoryIds: const ['exercise', 'learning'],
          fromMinutes: mins,
          message:
              'Swap $timeStr ${cat.name.toLowerCase()} for gym + reading',
        ));
      } else if (roi <= 2 && entry.value >= 120) {
        final cat = DefaultCategories.getById(entry.key);
        final halfMins = entry.value ~/ 2;
        final hours = halfMins ~/ 60;
        final remMins = halfMins % 60;
        final timeStr = hours > 0
            ? (remMins > 0 ? '${hours}h ${remMins}m' : '${hours}h')
            : '${halfMins}m';

        suggestions.add(TradeSuggestionItem(
          fromCategoryId: entry.key,
          toCategoryIds: const ['creative', 'selfcare'],
          fromMinutes: entry.value,
          message:
              'Try swapping $timeStr of ${cat.name.toLowerCase()} for creative time',
        ));
      }
    }

    return suggestions;
  }

  /// Calculate total coins for a day's activities.
  static int totalCoinsForDay(List<ActivityModel> activities) {
    return activities.fold<int>(
      0,
      (sum, a) => sum + calculateCoins(a.categoryId, a.durationMinutes),
    );
  }

  /// Calculate total expense for a day's activities.
  static double totalExpenseForDay(List<ActivityModel> activities) {
    return activities.fold<double>(
      0,
      (sum, a) => sum + a.expenseAmount,
    );
  }

  /// Compute the time penalty minutes when over budget.
  /// For every unit over the daily money budget, reduce remaining time
  /// proportionally: (overspend / budget) * totalBudgetMinutes, capped at 60.
  static int expensePenaltyMinutes({
    required double totalExpense,
    required double dailyMoneyBudget,
    required int dailyTimeBudgetMinutes,
  }) {
    if (dailyMoneyBudget <= 0 || totalExpense <= dailyMoneyBudget) return 0;
    final overspend = totalExpense - dailyMoneyBudget;
    final penalty = (overspend / dailyMoneyBudget * 60).round();
    return penalty.clamp(0, dailyTimeBudgetMinutes ~/ 4);
  }
}
