import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/stat_chip.dart';
import '../../../life_clock/presentation/widgets/life_clock_card.dart';
import '../../../time_market/presentation/widgets/level_badge.dart';
import '../bloc/time_wallet_bloc.dart';
import '../widgets/time_countdown_ring.dart';
import '../widgets/recent_activity_tile.dart';

class TimeWalletPage extends StatelessWidget {
  const TimeWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TimeWalletBloc, TimeWalletState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            context
                .read<TimeWalletBloc>()
                .add(const RefreshTimeWallet());
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Row(
                  children: [
                    Icon(
                      Icons.timelapse_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    const Text('Chronos'),
                  ],
                ),
                actions: [
                  Builder(
                    builder: (context) {
                      final storage =
                          context.read<StorageService>();
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: LevelBadge(
                          storageService: storage,
                          compact: true,
                        ),
                      );
                    },
                  ),
                  if (state.streakDays > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Chip(
                        avatar: const Icon(Icons.local_fire_department,
                            size: 18),
                        label: Text('${state.streakDays} day streak'),
                      ),
                    ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.list(
                  children: [
                    const SizedBox(height: 8),

                    // --- Countdown Ring ---
                    Center(
                      child: TimeCountdownRing(
                        spent: state.spentMinutes,
                        total: state.effectiveBudgetMinutes,
                      ),
                    ),

                    // Expense penalty warning
                    if (state.isOverBudget) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.error
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: theme.colorScheme.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Over budget! \$${state.todayExpense.toStringAsFixed(0)} spent '
                                '(limit: \$${state.dailyMoneyBudget.toStringAsFixed(0)}). '
                                '${state.expensePenaltyMinutes}m time penalty.',
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
                    const SizedBox(height: 24),

                    // --- Quick Stats ---
                    Row(
                      children: [
                        Expanded(
                          child: StatChip(
                            label: 'Spent',
                            value: state.spentDuration.formatted,
                            icon: Icons.hourglass_bottom_rounded,
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatChip(
                            label: 'Remaining',
                            value: state.remainingDuration.formatted,
                            icon: Icons.hourglass_top_rounded,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatChip(
                            label: 'Activities',
                            value: '${state.todayActivities.length}',
                            icon: Icons.checklist_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- Life Clock ---
                    const LifeClockCard(),
                    const SizedBox(height: 20),

                    // --- Recent Activities ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Spending",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/activities'),
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (state.todayActivities.isEmpty)
                      GlassCard(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.hourglass_empty_rounded,
                              size: 48,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No time spent yet today',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap + to log your first activity',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...state.todayActivities.take(5).map(
                            (activity) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8),
                              child:
                                  RecentActivityTile(activity: activity),
                            ),
                          ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
