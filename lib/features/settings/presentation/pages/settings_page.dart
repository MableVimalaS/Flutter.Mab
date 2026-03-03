import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/sync/firestore_sync_service.dart';
import '../../../activity/presentation/bloc/activity_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../life_clock/presentation/bloc/life_clock_bloc.dart';
import '../../../time_wallet/presentation/bloc/time_wallet_bloc.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Settings',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // --- Account ---
            _SectionHeader(title: 'Account'),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final user = FirebaseAuth.instance.currentUser;
                return _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: user?.email ?? 'Not signed in',
                  subtitle: user != null ? 'Signed in' : 'Sign in to sync data',
                );
              },
            ),
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              subtitle: 'Sign out and return to login',
              iconColor: theme.colorScheme.error,
              onTap: () => _showSignOutDialog(context),
            ),
            const SizedBox(height: 24),

            // --- Appearance ---
            _SectionHeader(title: 'Appearance'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Theme',
              subtitle: _themeModeLabel(state.themeMode),
              onTap: () => _showThemePicker(context, state.themeMode),
            ),
            const SizedBox(height: 24),

            // --- Time Budget ---
            _SectionHeader(title: 'Time Budget'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.timelapse_rounded,
              title: 'Daily Budget',
              subtitle: '${state.dailyBudgetHours} hours (awake time)',
              onTap: () =>
                  _showBudgetPicker(context, state.dailyBudgetHours),
            ),
            const SizedBox(height: 24),

            // --- Life Clock ---
            _SectionHeader(title: 'Life Clock'),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final storage = context.read<StorageService>();
                final dob = storage.dateOfBirth;
                return _SettingsTile(
                  icon: Icons.cake_rounded,
                  title: 'Date of Birth',
                  subtitle: dob != null
                      ? '${dob.day}/${dob.month}/${dob.year}'
                      : 'Not set — tap to configure',
                  onTap: () => _showDobPicker(context, dob),
                );
              },
            ),
            const SizedBox(height: 24),

            // --- Money Budget ---
            _SectionHeader(title: 'Money Budget'),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final storage = context.read<StorageService>();
                final budget = storage.dailyMoneyBudget;
                return _SettingsTile(
                  icon: Icons.attach_money_rounded,
                  title: 'Daily Spending Limit',
                  subtitle: budget > 0
                      ? '\$${budget.toStringAsFixed(0)} per day'
                      : 'Not set — tap to configure',
                  onTap: () => _showMoneyBudgetPicker(context, budget),
                );
              },
            ),
            const SizedBox(height: 24),

            // --- Help ---
            _SectionHeader(title: 'Help'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Guide',
              subtitle: 'Learn about all features',
              onTap: () => context.push('/help'),
            ),
            _SettingsTile(
              icon: Icons.replay_rounded,
              title: 'Replay Tour',
              subtitle: 'Show the guided tour again',
              onTap: () => _replayTour(context),
            ),
            const SizedBox(height: 24),

            // --- Data ---
            _SectionHeader(title: 'Data'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.cloud_sync_rounded,
              title: 'Sync Now',
              subtitle: 'Push local data to cloud',
              onTap: () => _syncNow(context),
            ),
            _SettingsTile(
              icon: Icons.delete_outline_rounded,
              title: 'Clear All Data',
              subtitle: 'Delete all logged activities',
              iconColor: theme.colorScheme.error,
              onTap: () => _showClearDialog(context),
            ),
            const SizedBox(height: 24),

            // --- About ---
            _SectionHeader(title: 'About'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: AppConstants.appName,
              subtitle:
                  'v${AppConstants.appVersion} — ${AppConstants.appTagline}',
            ),
            _SettingsTile(
              icon: Icons.movie_outlined,
              title: 'Inspired by',
              subtitle: '"In Time" (2011) — Time is currency',
            ),
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }

  String _themeModeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
        _ => 'System',
      };

  void _showSignOutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('You can sign back in to restore your data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, ThemeMode current) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choose Theme',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            for (final mode in ThemeMode.values)
              ListTile(
                leading: Icon(switch (mode) {
                  ThemeMode.light => Icons.light_mode_rounded,
                  ThemeMode.dark => Icons.dark_mode_rounded,
                  _ => Icons.settings_brightness_rounded,
                }),
                title: Text(_themeModeLabel(mode)),
                trailing: current == mode
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  context
                      .read<SettingsBloc>()
                      .add(ChangeThemeMode(mode));
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showBudgetPicker(BuildContext context, int current) {
    var selected = current;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Daily Awake Hours',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$selected hours',
                  style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(ctx).colorScheme.primary,
                      ),
                ),
                Slider(
                  value: selected.toDouble(),
                  min: 8,
                  max: 20,
                  divisions: 12,
                  label: '$selected hours',
                  onChanged: (v) =>
                      setModalState(() => selected = v.round()),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      context
                          .read<SettingsBloc>()
                          .add(ChangeDailyBudget(selected));
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDobPicker(BuildContext context, DateTime? current) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Select your date of birth',
    );
    if (picked != null && context.mounted) {
      context.read<LifeClockBloc>().add(SetBirthDate(picked));
    }
  }

  void _showMoneyBudgetPicker(BuildContext context, double current) {
    var selected = current > 0 ? current : 50.0;

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Daily Spending Limit',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${selected.toStringAsFixed(0)}',
                  style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(ctx).colorScheme.primary,
                      ),
                ),
                Slider(
                  value: selected,
                  min: 0,
                  max: 500,
                  divisions: 100,
                  label: '\$${selected.toStringAsFixed(0)}',
                  onChanged: (v) =>
                      setModalState(() => selected = v),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      context
                          .read<StorageService>()
                          .setDailyMoneyBudget(selected);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _replayTour(BuildContext context) {
    final storage = context.read<StorageService>();
    storage.resetCoachMarks();
    context.go('/wallet');
  }

  void _syncNow(BuildContext context) async {
    final syncService = context.read<FirestoreSyncService>();
    await syncService.fullSync();
    if (context.mounted) {
      context.showSnack('Data synced successfully');
    }
  }

  void _showClearDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your logged activities. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<SettingsBloc>().add(const ClearAllData());
              context.read<TimeWalletBloc>().add(const RefreshTimeWallet());
              context.read<ActivityBloc>().add(const LoadActivities());
              context.read<DashboardBloc>().add(const LoadDashboard());
              Navigator.pop(ctx);
              context.showSnack('All data cleared');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            letterSpacing: 1.5,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.4),
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? theme.colorScheme.primary)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor ?? theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right_rounded)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: onTap,
    );
  }
}
