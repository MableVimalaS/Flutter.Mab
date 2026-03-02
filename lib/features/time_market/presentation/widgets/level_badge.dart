import 'package:flutter/material.dart';

import '../../../../core/constants/rewards_config.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../shared/widgets/glass_card.dart';

class LevelBadge extends StatelessWidget {
  const LevelBadge({
    required this.storageService,
    this.compact = false,
    super.key,
  });

  final StorageService storageService;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCoins = storageService.totalCoins;
    final level = RewardsConfig.getLevel(totalCoins);
    final nextLevel = RewardsConfig.getNextLevel(totalCoins);
    final progress = RewardsConfig.getLevelProgress(totalCoins);

    if (compact) {
      return Chip(
        avatar: const Icon(Icons.monetization_on_rounded,
            size: 18, color: Colors.amber),
        label: Text(
          '$totalCoins coins',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on_rounded,
                  color: Colors.amber, size: 22),
              const SizedBox(width: 8),
              Text(
                level.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$totalCoins coins',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          if (nextLevel != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.amber.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation(Colors.amber),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${nextLevel.minCoins - totalCoins} coins to ${nextLevel.name}',
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Max level reached!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.amber.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
