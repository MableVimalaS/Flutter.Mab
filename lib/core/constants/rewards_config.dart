/// Rewards configuration for the Time Marketplace.
///
/// Defines ROI ratings, reward descriptions, coin formulas, and level thresholds.
class RewardsConfig {
  RewardsConfig._();

  /// ROI star ratings per category (1-5).
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
  };

  /// Trade quality labels based on ROI.
  static String tradeLabel(int stars) {
    if (stars >= 4) return 'GREAT TRADE';
    if (stars >= 2) return 'OKAY TRADE';
    return 'BAD TRADE';
  }

  /// Coins earned per 30 minutes for a given star rating.
  static int coinsPerHalfHour(int stars) => switch (stars) {
        5 => 10,
        4 => 7,
        3 => 5,
        2 => 2,
        _ => 0,
      };

  /// Calculate total coins for a given category and duration in minutes.
  static int calculateCoins(String categoryId, int durationMinutes) {
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
