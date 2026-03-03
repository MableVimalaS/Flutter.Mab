/// Rewards configuration for the Time Marketplace.
///
/// Defines ROI ratings, reward descriptions, coin formulas, and level thresholds.
class RewardsConfig {
  RewardsConfig._();

  /// ROI star ratings per category (0-5).
  static const Map<String, int> roi = {
    'exercise': 5,
    'learning': 5,
    'creative': 4,
    'selfcare': 4,
    'meals': 3,
    'work': 3,
    'social': 3,
    'commute': 2,
    'chores': 2,
    'entertainment': 2,
    'scrolling': 1,
    'other': 2,
    'smoking': 0,
    'drinking': 0,
    'junkfood': 0,
    'oversleeping': 0,
  };

  /// What you "buy" when you spend time on each category.
  static const Map<String, String> rewards = {
    'exercise': 'Health, energy, longevity',
    'learning': 'Knowledge, career growth',
    'creative': 'Skills, self-expression',
    'selfcare': 'Mental peace, recovery',
    'meals': 'Nutrition, saved money',
    'work': 'Income, progress',
    'social': 'Relationships, memories',
    'commute': 'Necessary cost',
    'chores': 'Clean space, order',
    'entertainment': 'Relaxation',
    'scrolling': 'Nothing. Bad trade.',
    'other': 'Varies',
    'smoking': 'Cancer risk, -11 min of life',
    'drinking': 'Liver damage, -15 min of life',
    'junkfood': 'Heart risk, -5 min of life',
    'oversleeping': 'Reduced lifespan, -8 min of life',
  };

  /// Trade quality labels based on ROI.
  static String tradeLabel(int stars) {
    if (stars >= 4) return 'GREAT TRADE';
    if (stars >= 2) return 'OKAY TRADE';
    if (stars >= 1) return 'BAD TRADE';
    return 'TERRIBLE TRADE';
  }

  /// Coins earned per 30 minutes for a given star rating.
  static int coinsPerHalfHour(int stars) => switch (stars) {
        5 => 10,
        4 => 7,
        3 => 5,
        2 => 2,
        _ => 0,
      };

  /// Life penalty minutes per session for bad habits.
  static const Map<String, int> badHabitPenaltyMinutes = {
    'smoking': 11,
    'drinking': 15,
    'junkfood': 5,
    'oversleeping': 8,
  };

  /// Whether a category is a bad habit.
  static bool isBadHabit(String categoryId) =>
      badHabitPenaltyMinutes.containsKey(categoryId);

  /// Coin penalty per session for bad habits (negative value).
  static int badHabitCoinPenalty(String categoryId) =>
      -(badHabitPenaltyMinutes[categoryId] ?? 0);

  /// Calculate total coins for a given category and duration in minutes.
  /// Bad habits return negative coins: ceil(duration/30) sessions x penalty.
  static int calculateCoins(String categoryId, int durationMinutes) {
    if (isBadHabit(categoryId)) {
      final sessions = (durationMinutes / 30).ceil();
      return sessions * badHabitCoinPenalty(categoryId);
    }
    final stars = roi[categoryId] ?? 2;
    final rate = coinsPerHalfHour(stars);
    return (rate * durationMinutes / 30).round();
  }

  /// Level thresholds: name → minimum coins required.
  static const List<Level> levels = [
    Level(name: 'Time Beginner', minCoins: 0, icon: ''),
    Level(name: 'Time Saver', minCoins: 100, icon: ''),
    Level(name: 'Time Investor', minCoins: 500, icon: ''),
    Level(name: 'Time Master', minCoins: 1500, icon: ''),
    Level(name: 'Time Millionaire', minCoins: 5000, icon: ''),
  ];

  /// Get current level for a given coin total.
  static Level getLevel(int totalCoins) {
    var current = levels.first;
    for (final level in levels) {
      if (totalCoins >= level.minCoins) {
        current = level;
      } else {
        break;
      }
    }
    return current;
  }

  /// Get the next level (or null if maxed out).
  static Level? getNextLevel(int totalCoins) {
    for (final level in levels) {
      if (totalCoins < level.minCoins) return level;
    }
    return null;
  }

  /// Progress fraction toward the next level (0.0 to 1.0).
  static double getLevelProgress(int totalCoins) {
    final current = getLevel(totalCoins);
    final next = getNextLevel(totalCoins);
    if (next == null) return 1.0;
    final range = next.minCoins - current.minCoins;
    if (range <= 0) return 1.0;
    return ((totalCoins - current.minCoins) / range).clamp(0.0, 1.0);
  }

  /// Average life expectancy used for Life Clock.
  static const int averageLifeExpectancyYears = 78;

  /// Bonus days added to life expectancy per level.
  static const Map<String, int> levelBonusDays = {
    'Time Beginner': 0,
    'Time Saver': 7,
    'Time Investor': 30,
    'Time Master': 90,
    'Time Millionaire': 180,
  };

  /// Bonus days from coins: every 100 coins = +1 day.
  static int coinBonusDays(int totalCoins) => totalCoins ~/ 100;

  /// Total life bonus days from level milestone + coin accumulation.
  static int totalLifeBonusDays(int totalCoins) {
    final level = getLevel(totalCoins);
    final fromLevel = levelBonusDays[level.name] ?? 0;
    return fromLevel + coinBonusDays(totalCoins);
  }
}

class Level {
  const Level({
    required this.name,
    required this.minCoins,
    required this.icon,
  });

  final String name;
  final int minCoins;
  final String icon;
}
