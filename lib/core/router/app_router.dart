import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../storage/storage_service.dart';
import '../../features/activity/presentation/pages/activity_page.dart';
import '../../features/activity/presentation/pages/add_activity_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/help/presentation/pages/help_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/time_wallet/presentation/pages/time_wallet_page.dart';
import '../../shared/widgets/adaptive_scaffold.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static const _authRoutes = ['/login', '/signup'];

  static GoRouter router(StorageService storageService) => GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: '/wallet',
        refreshListenable: GoRouterRefreshStream(
          FirebaseAuth.instance.authStateChanges(),
        ),
        redirect: (context, state) {
          final user = FirebaseAuth.instance.currentUser;
          final isLoggedIn = user != null;
          final location = state.uri.toString();
          final isOnAuthRoute = _authRoutes.contains(location);
          final isOnboarding = location == '/onboarding';
          final hasOnboarded = storageService.hasCompletedOnboarding;

          // Not logged in -> force to login (unless already on auth route)
          if (!isLoggedIn) {
            return isOnAuthRoute ? null : '/login';
          }

          // Logged in but on auth route -> redirect away
          if (isLoggedIn && isOnAuthRoute) {
            return hasOnboarded ? '/wallet' : '/onboarding';
          }

          // Logged in but not onboarded -> redirect to onboarding
          if (isLoggedIn && !hasOnboarded && !isOnboarding) {
            return '/onboarding';
          }

          return null;
        },
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: '/signup',
            builder: (context, state) => const SignupPage(),
          ),
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const OnboardingPage(),
          ),
          ShellRoute(
            navigatorKey: _shellNavigatorKey,
            builder: (context, state, child) =>
                AdaptiveScaffold(state: state, child: child),
            routes: [
              GoRoute(
                path: '/wallet',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TimeWalletPage(),
                ),
              ),
              GoRoute(
                path: '/activities',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ActivityPage(),
                ),
              ),
              GoRoute(
                path: '/dashboard',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DashboardPage(),
                ),
              ),
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsPage(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/add-activity',
            builder: (context, state) => const AddActivityPage(),
          ),
          GoRoute(
            path: '/help',
            builder: (context, state) => const HelpPage(),
          ),
        ],
      );
}
