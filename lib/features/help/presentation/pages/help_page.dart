import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const _sections = [
    _HelpSection(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Time Wallet',
      body:
          'Your Time Wallet shows today\'s time budget — like a bank account for hours. '
          'The countdown ring fills as you log activities. Your daily budget is the number '
          'of awake hours you set (default: 16h). Stay under budget to be "time-rich".',
    ),
    _HelpSection(
      icon: Icons.monetization_on_rounded,
      title: 'Time Coins',
      body:
          'Every activity earns or costs Time Coins based on its ROI rating.\n\n'
          '- 5-star activities (exercise, learning): +10 coins per 30 min\n'
          '- 4-star (creative, self-care): +7 coins per 30 min\n'
          '- 3-star (work, meals, social): +5 coins per 30 min\n'
          '- 2-star (commute, chores): +2 coins per 30 min\n'
          '- 1-star (scrolling): 0 coins\n'
          '- Bad habits (smoking, drinking): negative coins + life penalty\n\n'
          'Coins unlock levels and add bonus days to your Life Clock.',
    ),
    _HelpSection(
      icon: Icons.hourglass_full_rounded,
      title: 'Life Clock',
      body:
          'The Life Clock counts down your estimated remaining lifespan based on '
          'your date of birth and a 78-year average life expectancy.\n\n'
          'Good habits earn bonus days (e.g., reaching "Time Master" level adds 90 days). '
          'Bad habits apply life penalties that reduce your remaining time. '
          'Tap the card to see the full-screen countdown.',
    ),
    _HelpSection(
      icon: Icons.trending_up_rounded,
      title: 'Levels & Streaks',
      body:
          'Your level is based on total Time Coins earned:\n\n'
          '- Time Beginner: 0 coins\n'
          '- Time Saver: 100 coins\n'
          '- Time Investor: 500 coins\n'
          '- Time Master: 1,500 coins\n'
          '- Time Millionaire: 5,000 coins\n\n'
          'Each level adds life bonus days. Log activities daily to build streaks!',
    ),
    _HelpSection(
      icon: Icons.dashboard_rounded,
      title: 'Dashboard',
      body:
          'The Dashboard shows your weekly patterns with charts:\n\n'
          '- Category breakdown: where your time goes\n'
          '- Daily totals: hours logged per day this week\n'
          '- Trade analysis: which activities gave the best ROI\n\n'
          'Use this to spot trends and optimize your time spending.',
    ),
    _HelpSection(
      icon: Icons.cloud_sync_rounded,
      title: 'Cloud Sync',
      body:
          'Sign in with email or Google to sync your data across devices.\n\n'
          'Your activities, settings, coins, and life clock data are stored '
          'in the cloud. If you reinstall the app or switch devices, just '
          'sign in to restore everything.\n\n'
          'Data is always saved locally first (offline-first), then synced '
          'when you have a connection.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Guide'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final section = _sections[index];
          return _HelpCard(section: section);
        },
      ),
    );
  }
}

class _HelpSection {
  const _HelpSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.section});

  final _HelpSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            section.icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          section.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          Text(
            section.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
