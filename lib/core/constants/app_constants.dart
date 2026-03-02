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
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
}

class DefaultCategories {
  DefaultCategories._();

  static const List<TimeCategory> all = [
    TimeCategory(
      id: 'work',
      name: 'Work',
      icon: Icons.work_rounded,
      color: Color(0xFF5C6BC0),
    ),
    TimeCategory(
      id: 'exercise',
      name: 'Exercise',
      icon: Icons.fitness_center_rounded,
      color: Color(0xFF66BB6A),
    ),
    TimeCategory(
      id: 'learning',
      name: 'Learning',
      icon: Icons.school_rounded,
      color: Color(0xFFFFB74D),
    ),
    TimeCategory(
      id: 'social',
      name: 'Social',
      icon: Icons.people_rounded,
      color: Color(0xFFEF5350),
    ),
    TimeCategory(
      id: 'commute',
      name: 'Commute',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF78909C),
    ),
    TimeCategory(
      id: 'meals',
      name: 'Meals',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFF7043),
    ),
    TimeCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: Color(0xFFAB47BC),
    ),
    TimeCategory(
      id: 'selfcare',
      name: 'Self Care',
      icon: Icons.spa_rounded,
      color: Color(0xFF26C6DA),
    ),
    TimeCategory(
      id: 'chores',
      name: 'Chores',
      icon: Icons.cleaning_services_rounded,
      color: Color(0xFF8D6E63),
    ),
    TimeCategory(
      id: 'creative',
      name: 'Creative',
      icon: Icons.palette_rounded,
      color: Color(0xFFEC407A),
    ),
    TimeCategory(
      id: 'scrolling',
      name: 'Scrolling',
      icon: Icons.phone_android_rounded,
      color: Color(0xFFFF5252),
    ),
    TimeCategory(
      id: 'other',
      name: 'Other',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF9E9E9E),
    ),
  ];

  static TimeCategory getById(String id) {
    return all.firstWhere(
      (c) => c.id == id,
      orElse: () => all.last,
    );
  }
}
