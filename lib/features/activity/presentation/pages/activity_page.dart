import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/date_extensions.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../time_wallet/presentation/bloc/time_wallet_bloc.dart';
import '../../../time_wallet/presentation/widgets/recent_activity_tile.dart';
import '../bloc/activity_bloc.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Activity Log'),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today_rounded),
                onPressed: () => _pickDate(context, state.currentDate),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/add-activity'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Log Time'),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(context, state, theme),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ActivityState state,
    ThemeData theme,
  ) {
    final totalMinutes = state.activities
        .fold<int>(0, (sum, a) => sum + a.durationMinutes);

    return CustomScrollView(
      slivers: [
        // Date header + total
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.currentDate.formatted,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      state.currentDate.dayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Total: ${Duration(minutes: totalMinutes).formatted}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (state.activities.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: GlassCard(
                margin: const EdgeInsets.all(40),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hourglass_empty_rounded,
                      size: 56,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No activities logged',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start tracking where your time goes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.builder(
              itemCount: state.activities.length,
              itemBuilder: (context, index) {
                final activity = state.activities[index];
                return Dismissible(
                  key: ValueKey(activity.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    context
                        .read<ActivityBloc>()
                        .add(DeleteActivity(activity.id));
                    context
                        .read<TimeWalletBloc>()
                        .add(const RefreshTimeWallet());
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RecentActivityTile(activity: activity),
                  ),
                );
              },
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && context.mounted) {
      context.read<ActivityBloc>().add(ChangeDate(picked));
    }
  }
}
