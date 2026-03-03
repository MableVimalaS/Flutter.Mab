import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../storage/storage_service.dart';

class CoachMarkService {
  CoachMarkService._();

  static void showWalletTour({
    required BuildContext context,
    required StorageService storage,
    required GlobalKey countdownRingKey,
    required GlobalKey lifeClockKey,
    required GlobalKey fabKey,
    required GlobalKey navBarKey,
  }) {
    final targets = <TargetFocus>[
      TargetFocus(
        identify: 'countdown_ring',
        keyTarget: countdownRingKey,
        alignSkip: Alignment.bottomCenter,
        shape: ShapeLightFocus.RRect,
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _CoachContent(
              title: 'Time Countdown Ring',
              body:
                  'This shows how much of your daily time budget is spent. '
                  'The ring fills up as you log activities throughout the day.',
              onNext: controller.next,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'life_clock',
        keyTarget: lifeClockKey,
        alignSkip: Alignment.bottomCenter,
        shape: ShapeLightFocus.RRect,
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _CoachContent(
              title: 'Life Clock',
              body:
                  'Your life countdown based on average life expectancy. '
                  'Earn time coins from good habits to add bonus days!',
              onNext: controller.next,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'fab',
        keyTarget: fabKey,
        alignSkip: Alignment.topCenter,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _CoachContent(
              title: 'Log Activity',
              body:
                  'Tap here to log how you spent your time. '
                  'Each activity earns or costs time coins based on its ROI rating.',
              onNext: controller.next,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'nav_bar',
        keyTarget: navBarKey,
        alignSkip: Alignment.topCenter,
        shape: ShapeLightFocus.RRect,
        radius: 0,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _CoachContent(
              title: 'Navigation',
              body:
                  'Switch between Wallet, Activities, Dashboard, and Settings. '
                  'Explore your time data from different angles.',
              isLast: true,
              onNext: controller.next,
            ),
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.8,
      paddingFocus: 10,
      hideSkip: false,
      textSkip: 'SKIP',
      onFinish: () => storage.setCoachMarksShown(),
      onSkip: () {
        storage.setCoachMarksShown();
        return true;
      },
    ).show(context: context);
  }
}

class _CoachContent extends StatelessWidget {
  const _CoachContent({
    required this.title,
    required this.body,
    required this.onNext,
    this.isLast = false,
  });

  final String title;
  final String body;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onNext,
              child: Text(
                isLast ? 'GOT IT' : 'NEXT',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
