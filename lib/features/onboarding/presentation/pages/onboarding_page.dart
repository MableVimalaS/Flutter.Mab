import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/onboarding_bloc.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static const _pages = [
    _OnboardingData(
      icon: Icons.timelapse_rounded,
      title: 'Time is Currency',
      subtitle:
          'Inspired by "In Time" — your 24 hours are the most valuable '
          'currency you own. Spend them wisely.',
      color: Color(0xFF00E5FF),
    ),
    _OnboardingData(
      icon: Icons.track_changes_rounded,
      title: 'Track Every Minute',
      subtitle:
          'Log activities throughout your day. See exactly where your '
          'time currency goes — work, exercise, scrolling, or learning.',
      color: Color(0xFFFF6D00),
    ),
    _OnboardingData(
      icon: Icons.insights_rounded,
      title: 'Gain Insights',
      subtitle:
          'Beautiful charts show your spending patterns. Build streaks, '
          'set budgets, and become time-rich.',
      color: Color(0xFF66BB6A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<OnboardingBloc, OnboardingState>(
      listenWhen: (prev, curr) => curr.hasCompleted && !prev.hasCompleted,
      listener: (context, state) => context.go('/wallet'),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    // Sync bloc state if needed
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: page.color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              page.icon,
                              size: 56,
                              color: page.color,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            page.title,
                            style:
                                theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.subtitle,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- Dots + Buttons ---
              Padding(
                padding: const EdgeInsets.all(24),
                child: BlocBuilder<OnboardingBloc, OnboardingState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              width: i == state.currentPage ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: i == state.currentPage
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: () => _onNext(context, state),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              state.currentPage == _pages.length - 1
                                  ? "Let's Go!"
                                  : 'Next',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        if (state.currentPage < _pages.length - 1) ...[
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => _skip(context),
                            child: const Text('Skip'),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNext(BuildContext context, OnboardingState state) {
    if (state.currentPage >= _pages.length - 1) {
      context.read<OnboardingBloc>().add(const CompleteOnboarding());
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      context.read<OnboardingBloc>().add(const NextPage());
    }
  }

  void _skip(BuildContext context) {
    context.read<OnboardingBloc>().add(const CompleteOnboarding());
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}
