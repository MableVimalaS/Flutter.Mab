import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../utils/trade_calculator.dart';

class TradeCard extends StatelessWidget {
  const TradeCard({
    required this.tradeResult,
    super.key,
  });

  final TradeResult tradeResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = DefaultCategories.getById(tradeResult.categoryId);

    final glowColor = _glowColor(tradeResult.roi);
    final stars = List.generate(
      5,
      (i) => i < tradeResult.roi ? '\u2605' : '\u2606',
    ).join();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: glowColor.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stars + Trade label
            Text(
              stars,
              style: TextStyle(
                fontSize: 24,
                color: glowColor,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tradeResult.tradeLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: glowColor,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),

            // Divider
            Container(
              height: 1,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 16),

            // PAID
            _TradeRow(
              label: 'PAID',
              value: tradeResult.formattedDuration,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 8),

            // BOUGHT
            _TradeRow(
              label: 'BOUGHT',
              value: tradeResult.reward,
              color: glowColor,
            ),
            const SizedBox(height: 12),

            // Category
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat.icon, color: cat.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  cat.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cat.color,
                  ),
                ),
              ],
            ),

            // Expense if any
            if (tradeResult.expenseAmount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Spent: \$${tradeResult.expenseAmount.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            const SizedBox(height: 16),
            Container(
              height: 1,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 12),

            // Coins earned
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: Colors.amber, size: 20),
                const SizedBox(width: 6),
                Text(
                  tradeResult.coinsEarned > 0
                      ? '+${tradeResult.coinsEarned} Time Coins earned'
                      : 'No coins earned',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tradeResult.coinsEarned > 0
                        ? Colors.amber.shade700
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _glowColor(int roi) {
    if (roi >= 4) return Colors.green;
    if (roi >= 2) return Colors.orange;
    return Colors.red;
  }
}

class _TradeRow extends StatelessWidget {
  const _TradeRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              letterSpacing: 1.2,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
