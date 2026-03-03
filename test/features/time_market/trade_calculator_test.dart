import 'package:chronos/core/constants/rewards_config.dart';
import 'package:chronos/features/activity/data/models/activity_model.dart';
import 'package:chronos/features/time_market/utils/trade_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TradeCalculator', () {
    group('calculateCoins', () {
      test('5-star activity earns 10 coins per 30 min', () {
        // Exercise is 5 stars
        expect(TradeCalculator.calculateCoins('exercise', 30), 10);
        expect(TradeCalculator.calculateCoins('exercise', 60), 20);
        expect(TradeCalculator.calculateCoins('exercise', 90), 30);
      });

      test('4-star activity earns 7 coins per 30 min', () {
        // Creative is 4 stars
        expect(TradeCalculator.calculateCoins('creative', 30), 7);
        expect(TradeCalculator.calculateCoins('creative', 60), 14);
      });

      test('3-star activity earns 5 coins per 30 min', () {
        // Work is 3 stars
        expect(TradeCalculator.calculateCoins('work', 30), 5);
        expect(TradeCalculator.calculateCoins('work', 60), 10);
      });

      test('2-star activity earns 2 coins per 30 min', () {
        // Commute is 2 stars
        expect(TradeCalculator.calculateCoins('commute', 30), 2);
        expect(TradeCalculator.calculateCoins('commute', 60), 4);
      });

      test('1-star activity earns 0 coins', () {
        // Scrolling is 1 star
        expect(TradeCalculator.calculateCoins('scrolling', 30), 0);
        expect(TradeCalculator.calculateCoins('scrolling', 120), 0);
      });

      test('unknown category defaults to 2-star', () {
        expect(TradeCalculator.calculateCoins('unknown', 30), 2);
      });

      test('bad habit returns negative coins for smoking', () {
        // smoking: -11 coins per session, 30 min = 1 session
        expect(TradeCalculator.calculateCoins('smoking', 30), -11);
        // 60 min = ceil(60/30) = 2 sessions → -22
        expect(TradeCalculator.calculateCoins('smoking', 60), -22);
      });

      test('bad habit returns negative coins for drinking', () {
        expect(TradeCalculator.calculateCoins('drinking', 30), -15);
        expect(TradeCalculator.calculateCoins('drinking', 45), -30);
      });

      test('bad habit returns negative coins for junkfood', () {
        expect(TradeCalculator.calculateCoins('junkfood', 30), -5);
      });

      test('bad habit returns negative coins for oversleeping', () {
        expect(TradeCalculator.calculateCoins('oversleeping', 30), -8);
        expect(TradeCalculator.calculateCoins('oversleeping', 60), -16);
      });
    });

    group('getROI', () {
      test('returns correct ROI for known categories', () {
        expect(TradeCalculator.getROI('exercise'), 5);
        expect(TradeCalculator.getROI('learning'), 5);
        expect(TradeCalculator.getROI('creative'), 4);
        expect(TradeCalculator.getROI('selfcare'), 4);
        expect(TradeCalculator.getROI('work'), 3);
        expect(TradeCalculator.getROI('social'), 3);
        expect(TradeCalculator.getROI('meals'), 3);
        expect(TradeCalculator.getROI('commute'), 2);
        expect(TradeCalculator.getROI('chores'), 2);
        expect(TradeCalculator.getROI('entertainment'), 2);
        expect(TradeCalculator.getROI('scrolling'), 1);
        expect(TradeCalculator.getROI('other'), 2);
      });

      test('returns default 2 for unknown category', () {
        expect(TradeCalculator.getROI('nonexistent'), 2);
      });
    });

    group('evaluateTrade', () {
      test('returns correct trade result for exercise', () {
        final activity = ActivityModel(
          id: 'test',
          categoryId: 'exercise',
          durationMinutes: 60,
          date: DateTime.now(),
        );
        final result = TradeCalculator.evaluateTrade(activity);

        expect(result.roi, 5);
        expect(result.coinsEarned, 20);
        expect(result.tradeLabel, 'GREAT TRADE');
        expect(result.reward, 'Health, energy, longevity');
        expect(result.formattedDuration, '1h');
      });

      test('returns correct trade result for scrolling', () {
        final activity = ActivityModel(
          id: 'test',
          categoryId: 'scrolling',
          durationMinutes: 120,
          date: DateTime.now(),
        );
        final result = TradeCalculator.evaluateTrade(activity);

        expect(result.roi, 1);
        expect(result.coinsEarned, 0);
        expect(result.tradeLabel, 'BAD TRADE');
        expect(result.reward, 'Nothing. Bad trade.');
        expect(result.formattedDuration, '2h');
      });

      test('returns correct trade result for smoking (bad habit)', () {
        final activity = ActivityModel(
          id: 'test',
          categoryId: 'smoking',
          durationMinutes: 30,
          date: DateTime.now(),
        );
        final result = TradeCalculator.evaluateTrade(activity);

        expect(result.roi, 0);
        expect(result.coinsEarned, -11);
        expect(result.tradeLabel, 'TERRIBLE TRADE');
        expect(result.isBadHabit, true);
        expect(result.lifePenaltyMinutes, 11);
        expect(result.reward, 'Cancer risk, -11 min of life');
      });

      test('returns correct trade result for drinking (bad habit)', () {
        final activity = ActivityModel(
          id: 'test',
          categoryId: 'drinking',
          durationMinutes: 60,
          date: DateTime.now(),
        );
        final result = TradeCalculator.evaluateTrade(activity);

        expect(result.roi, 0);
        expect(result.coinsEarned, -30);
        expect(result.isBadHabit, true);
        expect(result.lifePenaltyMinutes, 30); // 2 sessions x 15 min
      });

      test('includes expense amount', () {
        final activity = ActivityModel(
          id: 'test',
          categoryId: 'meals',
          durationMinutes: 30,
          date: DateTime.now(),
          expenseAmount: 15.50,
        );
        final result = TradeCalculator.evaluateTrade(activity);

        expect(result.expenseAmount, 15.50);
      });
    });

    group('generateSuggestions', () {
      test('suggests swaps for scrolling with 30+ minutes', () {
        final categoryMinutes = {'scrolling': 60, 'work': 120};
        final suggestions =
            TradeCalculator.generateSuggestions(categoryMinutes);

        expect(suggestions.length, 1);
        expect(suggestions.first.fromCategoryId, 'scrolling');
        expect(suggestions.first.message, contains('scrolling'));
      });

      test('suggests swaps for 2-star with 120+ minutes', () {
        final categoryMinutes = {'entertainment': 180};
        final suggestions =
            TradeCalculator.generateSuggestions(categoryMinutes);

        expect(suggestions.length, 1);
        expect(suggestions.first.fromCategoryId, 'entertainment');
      });

      test('warns about bad habits with life penalty', () {
        final categoryMinutes = {'smoking': 30, 'exercise': 60};
        final suggestions =
            TradeCalculator.generateSuggestions(categoryMinutes);

        expect(suggestions.length, 1);
        expect(suggestions.first.fromCategoryId, 'smoking');
        expect(suggestions.first.message, contains('min of life'));
        expect(suggestions.first.message, contains('Smoking'));
      });

      test('warns about multiple bad habits', () {
        final categoryMinutes = {'smoking': 30, 'drinking': 60};
        final suggestions =
            TradeCalculator.generateSuggestions(categoryMinutes);

        expect(suggestions.length, 2);
        final ids = suggestions.map((s) => s.fromCategoryId).toSet();
        expect(ids, containsAll(['smoking', 'drinking']));
      });

      test('no suggestions for high-ROI activities', () {
        final categoryMinutes = {'exercise': 120, 'learning': 60};
        final suggestions =
            TradeCalculator.generateSuggestions(categoryMinutes);

        expect(suggestions, isEmpty);
      });
    });

    group('totalCoinsForDay', () {
      test('sums coins across activities', () {
        final activities = [
          ActivityModel(
            id: '1',
            categoryId: 'exercise',
            durationMinutes: 30,
            date: DateTime.now(),
          ),
          ActivityModel(
            id: '2',
            categoryId: 'work',
            durationMinutes: 60,
            date: DateTime.now(),
          ),
        ];
        // exercise 30m = 10 coins, work 60m = 10 coins
        expect(TradeCalculator.totalCoinsForDay(activities), 20);
      });
    });

    group('totalExpenseForDay', () {
      test('sums expenses across activities', () {
        final activities = [
          ActivityModel(
            id: '1',
            categoryId: 'meals',
            durationMinutes: 30,
            date: DateTime.now(),
            expenseAmount: 12.50,
          ),
          ActivityModel(
            id: '2',
            categoryId: 'commute',
            durationMinutes: 30,
            date: DateTime.now(),
            expenseAmount: 5.00,
          ),
        ];
        expect(TradeCalculator.totalExpenseForDay(activities), 17.50);
      });
    });

    group('expensePenaltyMinutes', () {
      test('returns 0 when under budget', () {
        expect(
          TradeCalculator.expensePenaltyMinutes(
            totalExpense: 30,
            dailyMoneyBudget: 50,
            dailyTimeBudgetMinutes: 960,
          ),
          0,
        );
      });

      test('returns penalty when over budget', () {
        final penalty = TradeCalculator.expensePenaltyMinutes(
          totalExpense: 100,
          dailyMoneyBudget: 50,
          dailyTimeBudgetMinutes: 960,
        );
        // (100-50)/50 * 60 = 60
        expect(penalty, 60);
      });

      test('returns 0 when budget is 0', () {
        expect(
          TradeCalculator.expensePenaltyMinutes(
            totalExpense: 100,
            dailyMoneyBudget: 0,
            dailyTimeBudgetMinutes: 960,
          ),
          0,
        );
      });

      test('caps penalty at 1/4 of daily time budget', () {
        final penalty = TradeCalculator.expensePenaltyMinutes(
          totalExpense: 10000,
          dailyMoneyBudget: 50,
          dailyTimeBudgetMinutes: 960,
        );
        expect(penalty, 240); // 960 / 4
      });
    });
  });

  group('RewardsConfig', () {
    group('levels', () {
      test('getLevel returns correct level for coin amounts', () {
        expect(RewardsConfig.getLevel(0).name, 'Time Beginner');
        expect(RewardsConfig.getLevel(50).name, 'Time Beginner');
        expect(RewardsConfig.getLevel(100).name, 'Time Saver');
        expect(RewardsConfig.getLevel(499).name, 'Time Saver');
        expect(RewardsConfig.getLevel(500).name, 'Time Investor');
        expect(RewardsConfig.getLevel(1500).name, 'Time Master');
        expect(RewardsConfig.getLevel(5000).name, 'Time Millionaire');
        expect(RewardsConfig.getLevel(99999).name, 'Time Millionaire');
      });

      test('getNextLevel returns next level or null at max', () {
        expect(RewardsConfig.getNextLevel(0)?.name, 'Time Saver');
        expect(RewardsConfig.getNextLevel(100)?.name, 'Time Investor');
        expect(RewardsConfig.getNextLevel(5000), null);
      });

      test('getLevelProgress returns 0-1 fraction', () {
        expect(RewardsConfig.getLevelProgress(0), 0.0);
        expect(RewardsConfig.getLevelProgress(50), 0.5);
        expect(RewardsConfig.getLevelProgress(100), 0.0); // start of new level
        expect(RewardsConfig.getLevelProgress(5000), 1.0); // maxed
      });
    });

    group('tradeLabel', () {
      test('returns correct labels', () {
        expect(RewardsConfig.tradeLabel(5), 'GREAT TRADE');
        expect(RewardsConfig.tradeLabel(4), 'GREAT TRADE');
        expect(RewardsConfig.tradeLabel(3), 'OKAY TRADE');
        expect(RewardsConfig.tradeLabel(2), 'OKAY TRADE');
        expect(RewardsConfig.tradeLabel(1), 'BAD TRADE');
        expect(RewardsConfig.tradeLabel(0), 'TERRIBLE TRADE');
      });
    });

    group('isBadHabit', () {
      test('returns true for bad habit categories', () {
        expect(RewardsConfig.isBadHabit('smoking'), true);
        expect(RewardsConfig.isBadHabit('drinking'), true);
        expect(RewardsConfig.isBadHabit('junkfood'), true);
        expect(RewardsConfig.isBadHabit('oversleeping'), true);
      });

      test('returns false for normal categories', () {
        expect(RewardsConfig.isBadHabit('exercise'), false);
        expect(RewardsConfig.isBadHabit('work'), false);
        expect(RewardsConfig.isBadHabit('scrolling'), false);
      });
    });

    group('totalLifeBonusDays', () {
      test('returns 0 for 0 coins (Beginner level)', () {
        expect(RewardsConfig.totalLifeBonusDays(0), 0);
      });

      test('returns level bonus + coin bonus at 100 coins (Time Saver)', () {
        // Level bonus: 7 days, coin bonus: 100/100 = 1 day
        expect(RewardsConfig.totalLifeBonusDays(100), 8);
      });

      test('returns level bonus + coin bonus at 500 coins (Time Investor)', () {
        // Level bonus: 30 days, coin bonus: 500/100 = 5 days
        expect(RewardsConfig.totalLifeBonusDays(500), 35);
      });

      test('returns level bonus + coin bonus at 1500 coins (Time Master)', () {
        // Level bonus: 90 days, coin bonus: 1500/100 = 15 days
        expect(RewardsConfig.totalLifeBonusDays(1500), 105);
      });

      test('returns level bonus + coin bonus at 5000 coins (Time Millionaire)', () {
        // Level bonus: 180 days, coin bonus: 5000/100 = 50 days
        expect(RewardsConfig.totalLifeBonusDays(5000), 230);
      });

      test('coinBonusDays scales linearly', () {
        expect(RewardsConfig.coinBonusDays(0), 0);
        expect(RewardsConfig.coinBonusDays(99), 0);
        expect(RewardsConfig.coinBonusDays(100), 1);
        expect(RewardsConfig.coinBonusDays(250), 2);
        expect(RewardsConfig.coinBonusDays(1000), 10);
      });
    });
  });
}
