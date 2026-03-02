import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Chronos';
  static const String appTagline = 'Time is Currency';
  static const String appVersion = '1.0.0';

  static const int defaultDailyHours = 16; // Awake hours (24 - 8 sleep)
  static const int maxActivityMinutes = 480; // 8 hours max per activity

  static const Duration animationDuration = Duration(milliseconds: 600);
  static const Duration quickAnimation = Duration(milliseconds: 300);

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}

class TimeCategory {
  const TimeCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.roi = 2,
    this.reward = 'Varies',
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int roi;
  final String reward;
}

class DefaultCategories {
  DefaultCategories._();

  static const List<TimeCategory> all = [
    TimeCategory(
      id: 'work',
      name: 'Work',
      icon: Icons.work_rounded,
      color: Color(0xFF5C6BC0),
      roi: 3,
      reward: 'Income, progress',
    ),
    TimeCategory(
      id: 'exercise',
      name: 'Exercise',
      icon: Icons.fitness_center_rounded,
      color: Color(0xFF66BB6A),
      roi: 5,
      reward: 'Health, energy, longevity',
    ),
    TimeCategory(
      id: 'learning',
      name: 'Learning',
      icon: Icons.school_rounded,
      color: Color(0xFFFFB74D),
      roi: 5,
      reward: 'Knowledge, career growth',
    ),
    TimeCategory(
      id: 'social',
      name: 'Social',
      icon: Icons.people_rounded,
      color: Color(0xFFEF5350),
      roi: 3,
      reward: 'Relationships, memories',
    ),
    TimeCategory(
      id: 'commute',
      name: 'Commute',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF78909C),
      roi: 2,
      reward: 'Necessary cost',
    ),
    TimeCategory(
      id: 'meals',
      name: 'Meals',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFF7043),
      roi: 3,
      reward: 'Nutrition, saved money',
    ),
    TimeCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: Color(0xFFAB47BC),
      roi: 2,
      reward: 'Relaxation',
    ),
    TimeCategory(
      id: 'selfcare',
      name: 'Self Care',
      icon: Icons.spa_rounded,
      color: Color(0xFF26C6DA),
      roi: 4,
      reward: 'Mental peace, recovery',
    ),
    TimeCategory(
      id: 'chores',
      name: 'Chores',
      icon: Icons.cleaning_services_rounded,
      color: Color(0xFF8D6E63),
      roi: 2,
      reward: 'Clean space, order',
    ),
    TimeCategory(
      id: 'creative',
      name: 'Creative',
      icon: Icons.palette_rounded,
      color: Color(0xFFEC407A),
      roi: 4,
      reward: 'Skills, self-expression',
    ),
    TimeCategory(
      id: 'scrolling',
      name: 'Scrolling',
      icon: Icons.phone_android_rounded,
      color: Color(0xFFFF5252),
      roi: 1,
      reward: 'Nothing. Bad trade.',
    ),
    TimeCategory(
      id: 'other',
      name: 'Other',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF9E9E9E),
      roi: 2,
      reward: 'Varies',
    ),
  ];

  static TimeCategory getById(String id) {
    return all.firstWhere(
      (c) => c.id == id,
      orElse: () => all.last,
    );
  }
}
