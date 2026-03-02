import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../utils/trade_calculator.dart';

class TradeSuggestionCard extends StatelessWidget {
  const TradeSuggestionCard({
    required this.suggestions,
    super.key,
  });

  final List<TradeSuggestionItem> suggestions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.swap_horiz_rounded,
                color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Trade Suggestions',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...suggestions.map((s) {
          final fromCat = DefaultCategories.getById(s.fromCategoryId);
          final toCats =
              s.toCategoryIds.map(DefaultCategories.getById).toList();

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.orange.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _CategoryChip(
                              icon: fromCat.icon,
                              color: fromCat.color,
                              label: fromCat.name),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.arrow_forward_rounded,
                                size: 14, color: Colors.orange),
                          ),
                          ...toCats.map((c) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: _CategoryChip(
                                    icon: c.icon,
                                    color: c.color,
                                    label: c.name),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
