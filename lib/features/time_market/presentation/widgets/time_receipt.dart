import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../utils/trade_calculator.dart';
import '../../../../features/activity/data/models/activity_model.dart';

class TimeReceipt extends StatelessWidget {
  const TimeReceipt({
    required this.activities,
    this.dailyMoneyBudget = 0.0,
    super.key,
  });

  final List<ActivityModel> activities;
  final double dailyMoneyBudget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCoins = TradeCalculator.totalCoinsForDay(activities);
    final totalExpense = TradeCalculator.totalExpenseForDay(activities);
    final totalMinutes =
        activities.fold<int>(0, (s, a) => s + a.durationMinutes);
    final totalDuration = Duration(minutes: totalMinutes);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'DAILY RECEIPT',
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateTime.now().formatted,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),

          // Line items
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Dashed divider
                _DashedDivider(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                ),
                const SizedBox(height: 12),

                // Each activity as a receipt line
                ...activities.map((a) {
                  final cat = DefaultCategories.getById(a.categoryId);
                  final coins = TradeCalculator.calculateCoins(
                      a.categoryId, a.durationMinutes);
                  final duration = Duration(minutes: a.durationMinutes);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(cat.icon, color: cat.color, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cat.name,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          duration.formatted,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 50,
                          child: Text(
                            coins >= 0 ? '+$coins' : '\u2212${coins.abs()}',
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: coins > 0
                                  ? Colors.amber.shade700
                                  : coins < 0
                                      ? Colors.red
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        if (a.expenseAmount > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '\$${a.expenseAmount.toStringAsFixed(0)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 8),
                _DashedDivider(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                ),
                const SizedBox(height: 12),

                // Totals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL TIME',
                      style: theme.textTheme.labelMedium?.copyWith(
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      totalDuration.formatted,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'COINS EARNED',
                      style: theme.textTheme.labelMedium?.copyWith(
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.monetization_on_rounded,
                            color: totalCoins < 0 ? Colors.red : Colors.amber,
                            size: 16),
                        const SizedBox(width: 4),
                        Text(
                          totalCoins >= 0
                              ? '+$totalCoins'
                              : '\u2212${totalCoins.abs()}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: totalCoins < 0
                                ? Colors.red
                                : Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (totalExpense > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MONEY SPENT',
                        style: theme.textTheme.labelMedium?.copyWith(
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${totalExpense.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: totalExpense > dailyMoneyBudget &&
                                  dailyMoneyBudget > 0
                              ? theme.colorScheme.error
                              : null,
                        ),
                      ),
                    ],
                  ),
                  if (dailyMoneyBudget > 0 &&
                      totalExpense > dailyMoneyBudget) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: theme.colorScheme.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Over budget by \$${(totalExpense - dailyMoneyBudget).toStringAsFixed(2)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 5.0;
        final dashCount = (constraints.maxWidth / (2 * dashWidth)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dashCount,
            (_) => SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            ),
          ),
        );
      },
    );
  }
}
