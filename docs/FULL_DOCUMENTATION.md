# Chronos - Complete Project Documentation

> **"Time is Currency"** — Inspired by the 2011 film *In Time*, Chronos treats your 24 hours as the most valuable currency you own.

---

## Table of Contents

1. [What is Chronos?](#1-what-is-chronos)
2. [Tech Stack](#2-tech-stack)
3. [Project Structure](#3-project-structure)
4. [How the App Starts (main.dart)](#4-how-the-app-starts-maindart)
5. [Authentication Flow (Sign Up → Sign In → Sign Out)](#5-authentication-flow)
6. [Routing & Navigation](#6-routing--navigation)
7. [Onboarding Flow](#7-onboarding-flow)
8. [Local Storage (Hive)](#8-local-storage-hive)
9. [Cloud Storage (Firebase Firestore)](#9-cloud-storage-firebase-firestore)
10. [State Management (BLoC Pattern)](#10-state-management-bloc-pattern)
11. [All BLoCs Explained](#11-all-blocs-explained)
12. [Data Models](#12-data-models)
13. [All Pages & Screens](#13-all-pages--screens)
14. [Shared Widgets](#14-shared-widgets)
15. [Activity Categories & Gamification](#15-activity-categories--gamification)
16. [Life Clock System](#16-life-clock-system)
17. [Time Coins & Levels](#17-time-coins--levels)
18. [Theming](#18-theming)
19. [Coach Marks (Tutorial Tour)](#19-coach-marks-tutorial-tour)
20. [Extensions & Utilities](#20-extensions--utilities)
21. [Responsive Design](#21-responsive-design)
22. [Firebase Setup](#22-firebase-setup)
23. [CI/CD Pipelines](#23-cicd-pipelines)
24. [Testing](#24-testing)
25. [Key Architecture Decisions](#25-key-architecture-decisions)
26. [Quick Reference Table](#26-quick-reference-table)

---

## 1. What is Chronos?

Chronos is a **Flutter time-tracking app** that gamifies your daily 24 hours. Instead of just logging time, you:

- **Spend time like currency** — every activity has an ROI (Return on Investment) rating
- **Earn time coins** — good activities (exercise, learning) earn coins; bad habits (smoking, scrolling) cost coins
- **Watch your Life Clock** — a real-time countdown showing how much life you have left, adjusted by your habits
- **Level up** — accumulate coins to unlock levels and bonus life days
- **Track expenses** — optional money tracking with time penalties for overspending

**Platforms:** Web, Android, iOS, Desktop (Flutter cross-platform)

---

## 2. Tech Stack

| Technology | What It Does | Why We Use It |
|-----------|-------------|---------------|
| **Flutter 3.19** | Cross-platform UI framework | One codebase → Web, Android, iOS, Desktop |
| **Dart** | Programming language | Flutter's native language, strongly typed |
| **flutter_bloc 8.x** | State management | Predictable state, separation of UI and logic |
| **GoRouter 14.x** | Navigation/Routing | Declarative routing, deep linking, auth guards |
| **Hive CE** | Local NoSQL database | Fast offline storage, no native dependencies |
| **Firebase Auth** | Authentication | Email/password + Google OAuth sign-in |
| **Cloud Firestore** | Cloud database | Real-time sync across devices |
| **fl_chart** | Charts library | Bar charts, pie charts for analytics |
| **Google Fonts** | Typography | Space Grotesk font family |
| **flutter_animate** | Animations | Declarative animation chains |
| **tutorial_coach_mark** | Tutorial overlays | First-time user guidance |
| **equatable** | Equality helpers | Immutable state comparison in BLoCs |
| **uuid** | ID generation | Unique activity IDs |
| **intl** | Internationalization | Date/time formatting |

### Dev Tools

| Tool | Purpose |
|------|---------|
| `bloc_test` | Unit testing BLoCs |
| `mocktail` | Mocking for tests |
| `build_runner` | Code generation (Hive adapters) |
| `hive_ce_generator` | Auto-generates Hive type adapters |
| `very_good_analysis` | Strict Dart linting rules |

---

## 3. Project Structure

```
lib/
├── main.dart                    ← App entry point
├── app.dart                     ← MaterialApp.router setup
│
├── core/                        ← Shared foundation code
│   ├── auth/
│   │   └── auth_repository.dart         ← Firebase Auth wrapper
│   ├── constants/
│   │   ├── app_constants.dart           ← Categories, breakpoints, version
│   │   └── rewards_config.dart          ← ROI ratings, coins, levels
│   ├── error/
│   │   └── failures.dart                ← Custom error types
│   ├── extensions/
│   │   ├── context_extensions.dart      ← BuildContext helpers
│   │   └── date_extensions.dart         ← DateTime/Duration formatting
│   ├── help/
│   │   └── coach_mark_service.dart      ← Tutorial overlay system
│   ├── router/
│   │   ├── app_router.dart              ← All routes + auth guards
│   │   └── go_router_refresh_stream.dart← Auth-driven route refresh
│   ├── storage/
│   │   └── storage_service.dart         ← Hive local storage wrapper
│   ├── sync/
│   │   └── firestore_sync_service.dart  ← Cloud sync logic
│   └── theme/
│       └── app_theme.dart               ← Light/dark Material 3 themes
│
├── features/                    ← Feature modules (clean architecture)
│   ├── activity/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── activity_model.dart      ← Hive model
│   │   │   │   ├── activity_model.g.dart    ← Auto-generated adapter
│   │   │   │   ├── time_category_model.dart
│   │   │   │   └── time_category_model.g.dart
│   │   │   └── repositories/
│   │   │       └── activity_repository_impl.dart ← Data access layer
│   │   └── presentation/
│   │       ├── bloc/activity_bloc.dart      ← CRUD + date filtering
│   │       └── pages/
│   │           ├── activity_page.dart       ← Activity list view
│   │           └── add_activity_page.dart   ← New activity form
│   │
│   ├── auth/
│   │   └── presentation/
│   │       ├── bloc/auth_bloc.dart          ← Auth state machine
│   │       ├── pages/
│   │       │   ├── login_page.dart          ← Sign in screen
│   │       │   └── signup_page.dart         ← Create account screen
│   │       └── widgets/
│   │           └── google_sign_in_button.dart
│   │
│   ├── dashboard/
│   │   └── presentation/
│   │       ├── bloc/dashboard_bloc.dart     ← Analytics aggregation
│   │       └── pages/dashboard_page.dart    ← Charts & insights
│   │
│   ├── help/
│   │   └── presentation/pages/help_page.dart
│   │
│   ├── life_clock/
│   │   └── presentation/
│   │       ├── bloc/life_clock_bloc.dart    ← Life countdown logic
│   │       └── widgets/
│   │           ├── life_clock_card.dart     ← Compact countdown
│   │           ├── life_clock_overlay.dart  ← Full-screen view
│   │           ├── arm_clock_painter.dart   ← Custom clock drawing
│   │           └── life_stat_row.dart       ← Stat display row
│   │
│   ├── onboarding/
│   │   └── presentation/
│   │       ├── bloc/onboarding_bloc.dart    ← 5-page flow control
│   │       └── pages/onboarding_page.dart   ← Intro + auth + DOB
│   │
│   ├── settings/
│   │   └── presentation/
│   │       ├── bloc/settings_bloc.dart      ← Theme, budgets
│   │       └── pages/settings_page.dart     ← All settings
│   │
│   ├── time_market/
│   │   ├── utils/trade_calculator.dart      ← Coin math
│   │   └── presentation/widgets/
│   │       ├── trade_card.dart              ← Activity result dialog
│   │       ├── trade_suggestion.dart        ← Smart suggestions
│   │       ├── time_receipt.dart            ← Daily receipt
│   │       └── level_badge.dart             ← Level display
│   │
│   └── time_wallet/
│       └── presentation/
│           ├── bloc/time_wallet_bloc.dart   ← Daily time budget
│           ├── pages/time_wallet_page.dart  ← Home screen
│           └── widgets/
│               ├── time_countdown_ring.dart ← Animated ring
│               └── recent_activity_tile.dart← Activity list item
│
└── shared/
    └── widgets/
        ├── adaptive_scaffold.dart   ← Responsive nav layout
        ├── glass_card.dart          ← Glassmorphism card
        ├── stat_chip.dart           ← Stat display chip
        └── info_tooltip.dart        ← Info icon with tooltip
```

---

## 4. How the App Starts (main.dart)

When you launch Chronos, here's exactly what happens, step by step:

```
User opens app
    │
    ▼
1. Flutter engine initializes
    │  WidgetsFlutterBinding.ensureInitialized()
    │
    ▼
2. Firebase initializes
    │  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
    │  This connects to your Firebase project (chronos-flutt)
    │
    ▼
3. Hive (local database) initializes
    │  Hive.initFlutter()
    │  Registers adapters:
    │    - ActivityModelAdapter (typeId: 0)
    │    - TimeCategoryModelAdapter (typeId: 1)
    │
    ▼
4. StorageService opens Hive boxes
    │  Opens 'activities' box (stores ActivityModel objects)
    │  Opens 'settings' box (stores key-value pairs)
    │
    ▼
5. Create service instances
    │  AuthRepository → wraps FirebaseAuth
    │  FirestoreSyncService → wraps Cloud Firestore
    │  ActivityRepositoryImpl → wraps StorageService for activities
    │
    ▼
6. Create BLoC providers (state managers)
    │  AuthBloc         → starts listening to auth state changes
    │  TimeWalletBloc   → loads today's time budget
    │  ActivityBloc     → loads today's activities
    │  DashboardBloc    → calculates weekly stats
    │  SettingsBloc     → loads saved settings
    │  LifeClockBloc    → starts life countdown timer
    │  OnboardingBloc   → checks if onboarding was completed
    │
    ▼
7. ChronosApp widget builds
    │  Sets up MaterialApp.router with:
    │    - Light theme (Material 3, cyan seed)
    │    - Dark theme (Material 3, dark navy)
    │    - Space Grotesk font
    │    - GoRouter for navigation
    │
    ▼
8. GoRouter evaluates redirect rules
    │  Is user logged in?
    │    NO  → Show /login page
    │    YES → Has completed onboarding?
    │           NO  → Show /onboarding
    │           YES → Show /wallet (home)
```

### Code walkthrough (simplified):

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Step 3: Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ActivityModelAdapter());
  Hive.registerAdapter(TimeCategoryModelAdapter());

  // Step 4: Open storage
  final storageService = StorageService();
  await storageService.init();

  // Step 5: Services
  final authRepository = AuthRepository();
  final syncService = FirestoreSyncService(storageService);
  final activityRepository = ActivityRepositoryImpl(storageService);

  // Step 6-8: Run app with all providers
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: storageService),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: syncService),
        RepositoryProvider.value(value: activityRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(authRepository)..add(AuthCheckRequested())),
          BlocProvider(create: (_) => TimeWalletBloc(...)..add(LoadTimeWallet())),
          // ... other BLoCs
        ],
        child: const ChronosApp(),
      ),
    ),
  );
}
```

---

## 5. Authentication Flow

### Overview

```
┌──────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION FLOW                         │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  NEW USER (Sign Up)           RETURNING USER (Sign In)        │
│  ─────────────────            ────────────────────────        │
│                                                               │
│  /signup page                 /login page                     │
│    ├─ Enter email              ├─ Enter email                 │
│    ├─ Enter password           ├─ Enter password              │
│    ├─ Confirm password         ├─ OR tap Google Sign In       │
│    ├─ Pick date of birth       └─ Submit                      │
│    ├─ OR tap Google Sign In         │                         │
│    └─ Submit                        │                         │
│         │                           │                         │
│         ▼                           ▼                         │
│  Firebase creates account    Firebase verifies credentials    │
│         │                           │                         │
│         ▼                           ▼                         │
│  Save DOB to Hive           Auto-complete onboarding         │
│  Complete onboarding         Mark coach marks shown           │
│         │                           │                         │
│         ▼                           ▼                         │
│         └───────────┬───────────────┘                         │
│                     │                                         │
│                     ▼                                         │
│              Navigate to /wallet (Home)                       │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Step-by-step: Sign Up (New User)

1. **User lands on `/signup` page**
2. **Fills the form:**
   - Email address (validated: must contain @)
   - Password (validated: minimum 6 characters)
   - Confirm password (must match)
   - Date of birth (date picker, used for Life Clock)
3. **Taps "Create Account"**
4. **What happens in code:**

```dart
// signup_page.dart → _submit()
void _submit() {
  // Validate form fields
  if (!(_formKey.currentState?.validate() ?? false)) return;

  // Ensure DOB is selected
  if (_dateOfBirth == null) {
    // Show error snackbar
    return;
  }

  // Dispatch sign-up event to AuthBloc
  context.read<AuthBloc>().add(AuthSignUpRequested(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  ));
}
```

5. **AuthBloc processes the event:**

```dart
// auth_bloc.dart → _onSignUp()
Future<void> _onSignUp(AuthSignUpRequested event, Emitter emit) async {
  emit(state.copyWith(isSubmitting: true));  // Show loading spinner

  try {
    // Call Firebase Auth to create account
    final credential = await _authRepository.signUpWithEmail(
      email: event.email,
      password: event.password,
    );

    // Success! Update state
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: credential.user,
      isSubmitting: false,
    ));
  } on FirebaseAuthException catch (e) {
    // Show human-readable error
    emit(state.copyWith(error: _mapAuthError(e.code)));
  }
}
```

6. **BlocListener in signup page catches the state change:**

```dart
BlocListener<AuthBloc, AuthState>(
  listenWhen: (prev, curr) =>
      curr.status == AuthStatus.authenticated &&
      prev.status != AuthStatus.authenticated,
  listener: (context, state) async {
    final storage = context.read<StorageService>();

    // Save DOB to local storage (Hive)
    await storage.setDateOfBirth(_dateOfBirth!);

    // Update Life Clock BLoC
    context.read<LifeClockBloc>().add(SetBirthDate(_dateOfBirth!));

    // Mark onboarding as complete (skip the 5-page flow)
    await storage.completeOnboarding();

    // Navigate to home
    context.go('/wallet');
  },
)
```

### Step-by-step: Sign In (Returning User)

1. **User lands on `/login` page**
2. **Enters email + password, OR taps Google Sign In**
3. **AuthBloc calls Firebase Auth to verify credentials**
4. **On success, BlocListener in login page:**

```dart
listener: (context, state) {
  final storage = context.read<StorageService>();

  // Returning user — skip onboarding entirely
  if (!storage.hasCompletedOnboarding) {
    storage.completeOnboarding();
  }

  // Don't show tutorial again
  if (!storage.hasShownCoachMarks) {
    storage.setCoachMarksShown();
  }

  // Go straight to home
  context.go('/wallet');
},
```

### Google Sign In

Works on both login and signup pages via `GoogleSignInButton`:

```dart
// google_sign_in_button.dart
onPressed: () {
  context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
}

// auth_bloc.dart → _onGoogleSignIn()
final credential = await _authRepository.signInWithGoogle();
// Opens Google OAuth popup/sheet → returns credential → same flow as email
```

### Sign Out

```dart
// Triggered from Settings page
context.read<AuthBloc>().add(const AuthSignOutRequested());

// auth_bloc.dart → _onSignOut()
await _authRepository.signOut();  // Firebase signs out
emit(AuthState(status: AuthStatus.unauthenticated));
// GoRouter detects auth change → redirects to /login
```

### Password Reset

```dart
// login_page.dart → _forgotPassword()
final repo = context.read<AuthRepository>();
await repo.sendPasswordResetEmail(email);
// Firebase sends a reset email → user clicks link → sets new password
```

### Where Credentials Are Stored

| What | Where | How |
|------|-------|-----|
| Firebase auth token | Browser/device storage | Managed by Firebase SDK automatically |
| User email | Firebase Auth | `FirebaseAuth.instance.currentUser?.email` |
| User UID | Firebase Auth | `FirebaseAuth.instance.currentUser?.uid` |
| Auth session | Firebase Auth | Persists across app restarts |
| Google OAuth token | Google Sign-In SDK | Managed by `google_sign_in` package |

---

## 6. Routing & Navigation

### How It Works

Chronos uses **GoRouter** for declarative routing. The router is configured in `app_router.dart`.

### All Routes

| Route | Page | Access | Description |
|-------|------|--------|-------------|
| `/login` | LoginPage | Public | Email/Google sign in |
| `/signup` | SignupPage | Public | Account creation + DOB |
| `/onboarding` | OnboardingPage | Auth required | 5-page intro (legacy) |
| `/wallet` | TimeWalletPage | Auth required | Home screen |
| `/activities` | ActivityPage | Auth required | Activity list |
| `/dashboard` | DashboardPage | Auth required | Charts & analytics |
| `/settings` | SettingsPage | Auth required | App configuration |
| `/add-activity` | AddActivityPage | Auth required | New activity form |
| `/help` | HelpPage | Auth required | Help & FAQ |

### Auth Guards (Redirect Logic)

Every time navigation occurs, the router checks:

```dart
redirect: (context, state) {
  final user = FirebaseAuth.instance.currentUser;
  final isLoggedIn = user != null;
  final location = state.uri.toString();
  final isOnAuthRoute = ['/login', '/signup'].contains(location);
  final hasOnboarded = storageService.hasCompletedOnboarding;

  // Rule 1: Not logged in → force to login
  if (!isLoggedIn && !isOnAuthRoute) return '/login';

  // Rule 2: Logged in but on login/signup → redirect to wallet
  if (isLoggedIn && isOnAuthRoute) {
    return hasOnboarded ? '/wallet' : '/onboarding';
  }

  // Rule 3: Logged in but hasn't onboarded → force onboarding
  if (isLoggedIn && !hasOnboarded && !isOnboarding) {
    return '/onboarding';
  }

  // Rule 4: Everything fine → continue
  return null;
}
```

### Route Refresh on Auth Change

```dart
refreshListenable: GoRouterRefreshStream(
  FirebaseAuth.instance.authStateChanges(),
),
```

This listens to Firebase's auth state stream. Whenever the user logs in or out, all redirect rules re-evaluate automatically.

### Shell Route (Tabbed Navigation)

The main app pages (`/wallet`, `/activities`, `/dashboard`, `/settings`) are wrapped in a **ShellRoute** with `AdaptiveScaffold`. This provides:

- **Mobile**: Bottom navigation bar
- **Tablet**: Navigation rail on the left
- **Desktop**: Full sidebar menu

```dart
ShellRoute(
  builder: (context, state, child) =>
      AdaptiveScaffold(state: state, child: child),
  routes: [
    GoRoute(path: '/wallet', ...),
    GoRoute(path: '/activities', ...),
    GoRoute(path: '/dashboard', ...),
    GoRoute(path: '/settings', ...),
  ],
)
```

---

## 7. Onboarding Flow

> **Note:** With the latest update, the signup page now collects DOB directly, so new users skip onboarding. The onboarding page is kept for edge cases.

### Original 5-Page Flow

| Page | Content | Required? |
|------|---------|-----------|
| 0 | "Time is Currency" intro | Skippable |
| 1 | "Track Every Minute" intro | Skippable |
| 2 | "Gain Insights" intro | Skippable |
| 3 | Auth (email signup / Google) | Mandatory |
| 4 | Date of Birth picker | Mandatory |

### How Completion Is Tracked

```dart
// StorageService
bool get hasCompletedOnboarding =>
    _settingsBox.get('onboarding_complete', defaultValue: false);

Future<void> completeOnboarding() async {
    await _settingsBox.put('onboarding_complete', true);
}
```

- Stored in Hive's `settings` box under key `'onboarding_complete'`
- Checked by the router on every navigation
- Set to `true` after completing the flow OR after sign-in/sign-up

---

## 8. Local Storage (Hive)

### What is Hive?

Hive is a **lightweight NoSQL database** for Flutter. Think of it as a super-fast local key-value store that can also store complex objects.

### Hive Boxes (Think: Database Tables)

| Box Name | Type | What It Stores |
|----------|------|----------------|
| `activities` | `Box<ActivityModel>` | All user activities |
| `settings` | `Box<dynamic>` | App settings as key-value pairs |

### Settings Box Keys

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `onboarding_complete` | `bool` | `false` | Has user completed setup? |
| `theme_mode` | `String` | `'system'` | `'light'`, `'dark'`, or `'system'` |
| `daily_hours_budget` | `int` | `16` | Daily awake hours (8-20) |
| `date_of_birth` | `String` | `null` | ISO 8601 date string |
| `birth_year` | `int` | `null` | Legacy: year only (migrated) |
| `total_coins` | `int` | `0` | Accumulated time coins |
| `life_penalty_minutes` | `int` | `0` | Total life penalty from bad habits |
| `daily_money_budget` | `double` | `0.0` | Daily spending limit ($) |
| `coach_marks_shown` | `bool` | `false` | Has tutorial been shown? |

### How Activities Are Stored

```dart
// Each activity is stored by its UUID key:
await _activitiesBox.put(activity.id, activity);

// Querying activities for a specific date:
List<ActivityModel> getActivitiesForDate(DateTime date) {
  return _activitiesBox.values.where((a) {
    return a.date.year == date.year &&
           a.date.month == date.month &&
           a.date.day == date.day;
  }).toList();
}
```

### How Hive Adapters Work

Hive needs to know how to serialize/deserialize custom objects. This is done with **adapters**:

```dart
// activity_model.dart
@HiveType(typeId: 0)  // Unique ID for this type
class ActivityModel extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String categoryId;
  @HiveField(2) final int durationMinutes;
  @HiveField(3) final DateTime date;
  @HiveField(4) final String note;
  @HiveField(5) final DateTime createdAt;
  @HiveField(6) final double expenseAmount;
}
```

Run `dart run build_runner build` to auto-generate the adapter file (`activity_model.g.dart`).

### DOB Migration

If a user had the old `birth_year` (integer) stored, it's automatically migrated:

```dart
DateTime? get dateOfBirth {
  // Try new format first
  final isoString = _settingsBox.get('date_of_birth') as String?;
  if (isoString != null) return DateTime.tryParse(isoString);

  // Fallback: old birth_year → Jan 1 of that year
  final oldYear = _settingsBox.get('birth_year') as int?;
  if (oldYear != null) return DateTime(oldYear);

  return null;
}
```

---

## 9. Cloud Storage (Firebase Firestore)

### Firestore Data Structure

```
firestore/
└── users/
    └── {uid}/                          ← One document per user
        ├── dateOfBirth: "1998-05-15"
        ├── themeMode: "dark"
        ├── dailyHoursBudget: 16
        ├── totalCoins: 350
        ├── lifePenaltyMinutes: 44
        ├── dailyMoneyBudget: 50.0
        ├── onboardingComplete: true
        ├── lastSyncedAt: Timestamp
        │
        └── activities/                 ← Subcollection
            └── {activityId}/
                ├── categoryId: "exercise"
                ├── durationMinutes: 60
                ├── date: "2026-03-04"
                ├── note: "Morning run"
                ├── expenseAmount: 0.0
                └── createdAt: "2026-03-04T07:30:00"
```

### Sync Strategy

```
┌─────────────────────────────────────────────────┐
│              SYNC FLOW                           │
├─────────────────────────────────────────────────┤
│                                                  │
│  On Login (fullSync):                            │
│    1. Pull cloud settings → apply to local       │
│    2. Pull cloud activities → merge with local   │
│    3. Push local activities → upload to cloud     │
│                                                  │
│  On Activity Save:                               │
│    1. Save to Hive (local) immediately           │
│    2. Push to Firestore (async, non-blocking)    │
│                                                  │
│  On Activity Delete:                             │
│    1. Delete from Hive immediately               │
│    2. Delete from Firestore (async)              │
│                                                  │
│  On Settings Change:                             │
│    1. Save to Hive immediately                   │
│    2. Push to Firestore (async)                  │
│                                                  │
│  Conflict Resolution:                            │
│    LOCAL ALWAYS WINS                             │
│    (Cloud is backup, not source of truth)        │
│                                                  │
│  Error Handling:                                 │
│    Sync errors are silently caught               │
│    App works 100% offline                        │
│                                                  │
└─────────────────────────────────────────────────┘
```

### Key Sync Methods

```dart
// Full sync on login
Future<void> fullSync() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final userDoc = _firestore.collection('users').doc(uid);

  // Pull cloud settings
  final snapshot = await userDoc.get();
  if (snapshot.exists) {
    _applyCloudSettings(snapshot.data()!);
  }

  // Pull cloud activities
  final activitiesSnapshot = await userDoc.collection('activities').get();
  for (final doc in activitiesSnapshot.docs) {
    final activity = _activityFromFirestore(doc.id, doc.data());
    await _storage.saveActivity(activity);
  }

  // Push local activities
  await _pushAllActivities();
}

// Push single activity
Future<void> pushActivity(ActivityModel activity) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  await _firestore
      .collection('users').doc(uid)
      .collection('activities').doc(activity.id)
      .set({ /* activity fields */ });
}
```

---

## 10. State Management (BLoC Pattern)

### What is BLoC?

BLoC stands for **Business Logic Component**. It's a pattern that separates UI from business logic:

```
┌─────────┐    Event     ┌──────┐    State     ┌─────────┐
│   UI    │ ──────────▶ │ BLoC │ ──────────▶  │   UI    │
│ (Page)  │             │      │              │ (Rebuilt)│
└─────────┘             └──────┘              └─────────┘

1. User taps a button → UI sends an Event to the BLoC
2. BLoC processes the event (calls APIs, does calculations)
3. BLoC emits a new State
4. UI rebuilds with the new state
```

### How BLoCs Are Provided

All BLoCs are created at the **root level** in `main.dart` using `MultiBlocProvider`:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => AuthBloc(authRepo)..add(AuthCheckRequested())),
    BlocProvider(create: (_) => TimeWalletBloc(...)..add(LoadTimeWallet())),
    // ... more BLoCs
  ],
  child: const ChronosApp(),
)
```

### How BLoCs Are Used in Widgets

```dart
// READING state (rebuilds when state changes):
BlocBuilder<TimeWalletBloc, TimeWalletState>(
  builder: (context, state) {
    return Text('${state.remainingMinutes} minutes left');
  },
)

// SENDING events:
context.read<ActivityBloc>().add(AddActivity(
  categoryId: 'exercise',
  durationMinutes: 60,
));

// LISTENING for one-time actions (navigation, snackbars):
BlocListener<AuthBloc, AuthState>(
  listenWhen: (prev, curr) => curr.status == AuthStatus.authenticated,
  listener: (context, state) {
    context.go('/wallet');  // Navigate on auth success
  },
)
```

---

## 11. All BLoCs Explained

### 11.1 AuthBloc

**File:** `lib/features/auth/presentation/bloc/auth_bloc.dart`

| Event | What It Does |
|-------|-------------|
| `AuthCheckRequested` | Check if user is already logged in (on app start) |
| `AuthSignUpRequested(email, password)` | Create new account via Firebase |
| `AuthSignInRequested(email, password)` | Sign in with email/password |
| `AuthGoogleSignInRequested` | Sign in with Google OAuth |
| `AuthSignOutRequested` | Sign out and clear session |
| `_AuthUserChanged(user)` | Internal: fired when Firebase auth state changes |

**State:**
```dart
AuthStatus: unknown → authenticated OR unauthenticated
User?: Firebase User object (has email, uid, displayName)
String? error: Human-readable error message
bool isSubmitting: True while API call is in progress
```

**Special behavior:** Subscribes to `authRepository.authStateChanges` stream. Any external auth change (token refresh, session expiry) automatically updates the BLoC state.

---

### 11.2 TimeWalletBloc

**File:** `lib/features/time_wallet/presentation/bloc/time_wallet_bloc.dart`

| Event | What It Does |
|-------|-------------|
| `LoadTimeWallet` | Calculate today's time budget state |
| `RefreshTimeWallet` | Recalculate (after adding/deleting activity) |

**State:**
```dart
totalBudgetMinutes: 960          // 16 hours × 60
spentMinutes: 180                // Sum of today's activity durations
todayActivities: [...]           // List of today's activities
streakDays: 5                    // Consecutive days with activities
expensePenaltyMinutes: 30        // Penalty for overspending money
todayExpense: 75.0               // Total money spent today
dailyMoneyBudget: 50.0           // Budget limit

// Computed:
effectiveBudgetMinutes = totalBudgetMinutes - expensePenaltyMinutes
remainingMinutes = effectiveBudgetMinutes - spentMinutes
spentFraction = spentMinutes / effectiveBudgetMinutes  // 0.0 to 1.0+
isOverBudget = dailyMoneyBudget > 0 && todayExpense > dailyMoneyBudget
```

**Expense penalty formula:**
```
If todayExpense > dailyMoneyBudget:
  overspend = todayExpense - dailyMoneyBudget
  penalty = (overspend / dailyMoneyBudget) × 60 minutes
  capped at: totalBudgetMinutes / 4  (max 4 hours penalty)
```

---

### 11.3 ActivityBloc

**File:** `lib/features/activity/presentation/bloc/activity_bloc.dart`

| Event | What It Does |
|-------|-------------|
| `LoadActivities` | Load activities for current date |
| `AddActivity(categoryId, duration, note, expense)` | Create + save + sync + reward |
| `DeleteActivity(activityId)` | Delete locally + sync |
| `ChangeDate(date)` | Switch to viewing a different date |

**What happens when you add an activity:**
1. Create `ActivityModel` with UUID, timestamp, category, duration
2. Save to Hive via `StorageService`
3. Calculate coins: `RewardsConfig.calculateCoins(categoryId, duration)`
4. Add coins to storage: `storage.addCoins(coins)`
5. If bad habit: add life penalty minutes
6. Sync to Firestore: `syncService.pushActivity(activity)`
7. Reload activities list

---

### 11.4 DashboardBloc

**File:** `lib/features/dashboard/presentation/bloc/dashboard_bloc.dart`

| Event | What It Does |
|-------|-------------|
| `LoadDashboard` | Aggregate weekly analytics |

**State provides:**
- `weeklyCategoryTotals`: Map of category → total minutes this week
- `dailyTotals`: List of (date, minutes) for the last 7 days
- `todayCategoryMinutes`: Map of category → minutes today
- `streakDays`: Consecutive active days
- `weekTotalMinutes`: Total minutes logged this week

---

### 11.5 SettingsBloc

**File:** `lib/features/settings/presentation/bloc/settings_bloc.dart`

| Event | What It Does |
|-------|-------------|
| `LoadSettings` | Read theme, budget from Hive |
| `ChangeThemeMode(mode)` | Update theme + sync |
| `ChangeDailyBudget(hours)` | Update time budget + sync |
| `ClearAllData` | Delete all activities from Hive |

---

### 11.6 LifeClockBloc

**File:** `lib/features/life_clock/presentation/bloc/life_clock_bloc.dart`

| Event | What It Does |
|-------|-------------|
| `LoadLifeClock` | Load DOB + start 1-second timer |
| `SetBirthDate(date)` | Save DOB + recalculate |
| `SetBirthYear(year)` | Legacy: save year only |
| `RefreshLifeAdjustments` | Recalculate bonus/penalty days |
| `_Tick` | Internal: fires every second |

**Life calculation:**
```
baseLifeDays = 78 years × 365 days = 28,470 days
bonusDays = levelBonus + (totalCoins / 100)
penaltyDays = lifePenaltyMinutes / 1440  (convert minutes to days)

totalLifeDays = baseLifeDays + bonusDays
deathDate = dateOfBirth + totalLifeDays

remainingDuration = deathDate - now
elapsedDuration = now - dateOfBirth
lifeFraction = elapsed / total  (0.0 to 1.0)
```

The timer ticks every second, so the countdown updates in real-time.

---

### 11.7 OnboardingBloc

**File:** `lib/features/onboarding/presentation/bloc/onboarding_bloc.dart`

| Event | What It Does |
|-------|-------------|
| `CheckOnboarding` | Check if already completed |
| `CompleteOnboarding` | Mark as done in Hive |
| `NextPage` | Go to next page (with guards) |
| `PreviousPage` | Go to previous page |
| `GoToPage(page)` | Jump to specific page |
| `SetAuthComplete` | Mark auth step done |
| `SetDateOfBirth(date)` | Save DOB |

**Page guards:**
- Page 3 → 4: Blocked until `isAuthComplete == true`
- Page 4 → Complete: Blocked until `dateOfBirth != null`

---

## 12. Data Models

### ActivityModel

```dart
@HiveType(typeId: 0)
class ActivityModel extends HiveObject {
  @HiveField(0) final String id;           // UUID v4
  @HiveField(1) final String categoryId;   // e.g., "exercise", "work"
  @HiveField(2) final int durationMinutes;  // 5-480 minutes
  @HiveField(3) final DateTime date;        // Activity date
  @HiveField(4) final String note;          // User's note
  @HiveField(5) final DateTime createdAt;   // When it was logged
  @HiveField(6) final double expenseAmount; // Money spent ($)

  Duration get duration => Duration(minutes: durationMinutes);

  ActivityModel copyWith({...});  // Create modified copy
}
```

**Example activity:**
```dart
ActivityModel(
  id: '550e8400-e29b-41d4-a716-446655440000',
  categoryId: 'exercise',
  durationMinutes: 60,
  date: DateTime(2026, 3, 4),
  note: 'Morning run in the park',
  createdAt: DateTime(2026, 3, 4, 7, 30),
  expenseAmount: 0.0,
)
```

### TimeCategoryModel

```dart
@HiveType(typeId: 1)
class TimeCategoryModel extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
}
```

> Most category data comes from the hardcoded `DefaultCategories.all` list, not from Hive.

---

## 13. All Pages & Screens

### 13.1 TimeWalletPage (Home — `/wallet`)

The main screen showing your daily time budget.

**Sections from top to bottom:**
1. **App Bar** — "Chronos" title + level badge + streak chip
2. **Time Countdown Ring** — Animated circular progress of time spent
3. **Expense Warning** — Red banner if over money budget (shows penalty)
4. **Quick Stats Row** — Three chips: Spent, Remaining, Activities count
5. **Life Clock Card** — Compact life countdown (tap for full view)
6. **Today's Spending** — Recent activity list (top 5) with "See all" link
7. **FAB** — Floating "+" button to add activity

### 13.2 ActivityPage (`/activities`)

View and manage activities for any date.

**Features:**
- Date picker in app bar (switch to any date)
- Total time badge showing minutes logged
- Activity list sorted by creation time (newest first)
- Swipe-to-delete on each activity
- FAB to add new activity

### 13.3 AddActivityPage (`/add-activity`)

Form to log a new time activity.

**Form flow:**
1. **Category Grid** — 16 animated category buttons with icons & colors
2. **Duration Slider** — 5 to 480 minutes with live display
3. **Quick Duration Chips** — Tap [15m] [30m] [45m] [1h] [1.5h] [2h]
4. **Note Field** — Optional text input
5. **Expense Field** — Optional dollar amount
6. **Save Button** — Creates activity, shows trade result dialog

**After saving:**
- Shows `TradeCard` dialog with:
  - Trade quality (GREAT / OKAY / BAD / TERRIBLE)
  - Coins earned or lost
  - What you "bought" with your time
  - Life impact (if bad habit)

### 13.4 DashboardPage (`/dashboard`)

Weekly analytics and insights.

**Sections:**
1. **Quick Stats** — Streak, Today total, Week total
2. **Level Badge** — Current level + progress bar to next
3. **Today's Receipt** — Activity-by-activity breakdown with coins
4. **Trade Suggestions** — Smart tips based on your patterns
5. **Daily Bar Chart** — 7-day bar chart (hours per day)
6. **Category Pie Chart** — Donut chart of time distribution
7. **Category Breakdown** — Horizontal bars with percentages

### 13.5 SettingsPage (`/settings`)

All app configuration.

**Sections:**
| Section | Settings |
|---------|----------|
| Account | Email display, Sign Out button |
| Appearance | Theme: Light / Dark / System |
| Time Budget | Daily awake hours slider (8-20h) |
| Life Clock | Date of birth picker |
| Money Budget | Daily spending limit slider ($0-500) |
| Help | Help page link, Replay tutorial tour |
| Data | Sync now, Clear all data |
| About | App version, inspiration note |

### 13.6 LoginPage (`/login`)

Sign in for returning users.

**Fields:** Email, Password, Forgot password link
**Actions:** Sign In button, Google Sign In button, "Don't have an account? Sign Up" link

### 13.7 SignupPage (`/signup`)

Account creation for new users.

**Fields:** Email, Password, Confirm password, Date of birth picker
**Actions:** Create Account button, Google Sign In button, "Already have an account? Sign In" link

### 13.8 HelpPage (`/help`)

Help information and FAQ.

---

## 14. Shared Widgets

### AdaptiveScaffold

Responsive layout that automatically switches navigation style:

```
Mobile (<600px)         Tablet (600-900px)       Desktop (>900px)
┌──────────────┐       ┌──┬───────────┐         ┌─────┬──────────┐
│              │       │  │           │         │     │          │
│   Content    │       │R │  Content  │         │Side │ Content  │
│              │       │a │           │         │bar  │          │
│              │       │i │           │         │     │          │
│              │       │l │           │         │     │          │
├──────────────┤       │  │           │         │     │          │
│  Bottom Nav  │       └──┴───────────┘         └─────┴──────────┘
└──────────────┘
```

**Tabs:** Wallet, Activities, Dashboard, Settings

### GlassCard

Glassmorphism effect container with blurred background:

```dart
GlassCard(
  padding: EdgeInsets.all(16),
  child: Text('Content here'),
)
// Creates: frosted glass look with blur + semi-transparent background
```

### StatChip

Small stat display with icon, value, and label:

```dart
StatChip(
  label: 'Spent',
  value: '3h 20m',
  icon: Icons.hourglass_bottom_rounded,
  color: Colors.red,
)
```

### InfoTooltip

Tappable info icon that shows an overlay tooltip:

```dart
InfoTooltip(message: 'Your streak counts consecutive days...')
```

---

## 15. Activity Categories & Gamification

### All 16 Categories

| Category | Icon | Color | ROI | Reward | Bad Habit? |
|----------|------|-------|-----|--------|------------|
| Work | briefcase | Indigo | 3/5 | Income, progress | No |
| Exercise | dumbbell | Green | 5/5 | Health, energy, longevity | No |
| Learning | graduation cap | Amber | 5/5 | Knowledge, career growth | No |
| Social | people | Red | 3/5 | Relationships, memories | No |
| Commute | car | Blue Grey | 2/5 | Necessary cost | No |
| Meals | restaurant | Deep Orange | 3/5 | Nutrition, saved money | No |
| Entertainment | movie | Purple | 2/5 | Relaxation | No |
| Self Care | spa | Cyan | 4/5 | Mental peace, recovery | No |
| Chores | cleaning | Brown | 2/5 | Clean space, order | No |
| Creative | palette | Pink | 4/5 | Skills, self-expression | No |
| Scrolling | phone | Red | 1/5 | Nothing. Bad trade. | No |
| Other | dots | Grey | 2/5 | Varies | No |
| **Smoking** | cigarette | Dark Red | 0/5 | Cancer risk, -11 min of life | **Yes** |
| **Drinking** | cocktail | Dark Purple | 0/5 | Liver damage, -15 min of life | **Yes** |
| **Junk Food** | fast food | Dark Orange | 0/5 | Heart risk, -5 min of life | **Yes** |
| **Oversleeping** | bed | Dark Blue | 0/5 | Reduced lifespan, -8 min of life | **Yes** |

### ROI & Trade Quality

| ROI Stars | Trade Label | Coins per 30 min |
|-----------|-------------|-------------------|
| 5 | GREAT TRADE | +10 coins |
| 4 | GREAT TRADE | +7 coins |
| 3 | OKAY TRADE | +5 coins |
| 2 | OKAY TRADE | +2 coins |
| 1 | BAD TRADE | 0 coins |
| 0 | TERRIBLE TRADE | Negative (penalty) |

### Bad Habit Penalties

| Habit | Coin Penalty (per 30 min) | Life Penalty (per 30 min) |
|-------|---------------------------|---------------------------|
| Smoking | -11 coins | -11 minutes of life |
| Drinking | -15 coins | -15 minutes of life |
| Junk Food | -5 coins | -5 minutes of life |
| Oversleeping | -8 coins | -8 minutes of life |

---

## 16. Life Clock System

### How It Works

The Life Clock calculates how much time you have left to live, based on:

1. **Your date of birth** (entered during signup or in settings)
2. **Average life expectancy** (78 years)
3. **Bonus days** earned from good habits (coins + level)
4. **Penalty minutes** accumulated from bad habits

### Calculation

```
Base life = 78 years = 28,470 days

Bonus days:
  From level:
    Time Beginner (0+ coins)    = +0 days
    Time Saver (100+ coins)     = +7 days
    Time Investor (500+ coins)  = +30 days
    Time Master (1500+ coins)   = +90 days
    Time Millionaire (5000+ coins) = +180 days
  From coins:
    Every 100 coins = +1 day
  Total bonus = levelBonus + (totalCoins ÷ 100)

Penalty:
  Accumulated from bad habits
  e.g., Smoking 30 min = -11 minutes of life
  These add up over time

Adjusted life = 28,470 + bonusDays days
Remaining = (birthDate + adjustedLife) - now
```

### Display

The Life Clock shows:
- **YRS : MOS : DAYS : HRS : MIN : SEC** countdown
- Progress bar showing elapsed life percentage
- Color coding: Green (<50% elapsed), Orange (50-75%), Red (>75%)
- Bonus days earned indicator
- Tap to expand to full-screen overlay with arm clock visualization

### ArmClockPainter

A custom `CustomPainter` that draws an analog clock-style visualization of life elapsed. The "arm" sweeps based on life fraction.

---

## 17. Time Coins & Levels

### How Coins Are Earned

```
When you log an activity:
  coins = ROI_rate × (duration_minutes ÷ 30)

Examples:
  60 min Exercise (5★) = 10 × 2 = 20 coins
  30 min Work (3★)     = 5 × 1  = 5 coins
  90 min Scrolling (1★) = 0 × 3 = 0 coins
  30 min Smoking (0★)  = -11 × 1 = -11 coins (penalty!)
```

### Level System

| Level | Min Coins | Bonus Life Days |
|-------|-----------|-----------------|
| Time Beginner | 0 | 0 days |
| Time Saver | 100 | 7 days |
| Time Investor | 500 | 30 days |
| Time Master | 1,500 | 90 days |
| Time Millionaire | 5,000 | 180 days |

Plus: Every 100 coins = +1 bonus day (continuously)

**Level progress** is shown on the Dashboard page as a progress bar from current level to next.

---

## 18. Theming

### Material 3 Design

Chronos uses **Material 3** (Material You) with dynamic color schemes generated from a seed color.

**Seed color:** `#00E5FF` (Cyan)

### Light Theme

```dart
ColorScheme.fromSeed(
  seedColor: Color(0xFF00E5FF),
  brightness: Brightness.light,
)
// Scaffold: white
// Cards: semi-transparent surface
// FAB: Deep Orange (#FF6D00)
```

### Dark Theme

```dart
ColorScheme.fromSeed(
  seedColor: Color(0xFF00E5FF),
  brightness: Brightness.dark,
)
// Scaffold: Dark Navy (#0A0E21)
// Cards: white with 5% opacity
// FAB: Deep Orange (#FF6D00)
```

### Typography

**Font:** Space Grotesk (Google Fonts)
- Modern, geometric sans-serif
- Applied globally via `GoogleFonts.spaceGroteskTextTheme()`

### Theme Switching

Users choose theme in Settings → Appearance:
- **Light** — Always light mode
- **Dark** — Always dark mode
- **System** — Follows device setting (default)

```dart
// Stored in Hive:
storage.setThemeMode('dark');  // 'light', 'dark', or 'system'

// Applied in app.dart:
MaterialApp.router(
  themeMode: state.themeMode,  // From SettingsBloc
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
)
```

---

## 19. Coach Marks (Tutorial Tour)

### What It Is

An interactive overlay that highlights UI elements and explains them to new users.

### Tour Stops (4 steps)

| Step | Target | Title | Explanation |
|------|--------|-------|-------------|
| 1 | Countdown Ring | "Time Countdown Ring" | Shows daily time budget usage |
| 2 | Life Clock Card | "Life Clock" | Life countdown with bonus days |
| 3 | FAB (+) button | "Log Activity" | How to add activities + coin rewards |
| 4 | Navigation Bar | "Navigation" | Switch between app sections |

### When It Shows

```dart
// time_wallet_page.dart → initState()
void _maybeShowCoachMarks() {
  final storage = context.read<StorageService>();
  if (!storage.hasShownCoachMarks && storage.hasCompletedOnboarding) {
    CoachMarkService.showWalletTour(...);
  }
}
```

- Shows **only once** — first time opening the wallet after onboarding
- Marked as shown after completion OR skip
- Can be replayed from Settings → "Replay Tour"

### Persistence

```dart
// Stored in Hive:
'coach_marks_shown': true/false

// Sign-in auto-marks as shown (returning users don't need it)
// Sign-up does NOT auto-mark (new users see it on first wallet visit)
```

---

## 20. Extensions & Utilities

### DateTime Extensions (`date_extensions.dart`)

```dart
DateTime date = DateTime(2026, 3, 4, 14, 30);

date.formatted       // "Mar 4, 2026"
date.dayMonth        // "Mar 4"
date.timeFormatted   // "2:30 PM"
date.dayName         // "Wednesday"
date.shortDay        // "Wed"
date.startOfDay      // DateTime(2026, 3, 4, 0, 0, 0)
date.startOfWeek     // Monday of this week
date.daysOfWeek      // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
date.isSameDay(other) // true if same year/month/day
```

### Duration Extensions (`date_extensions.dart`)

```dart
Duration d = Duration(hours: 2, minutes: 30);

d.formatted     // "2h 30m"
d.hoursDecimal  // "2.5"

Duration d2 = Duration(minutes: 45);
d2.formatted    // "45m"
```

### Context Extensions (`context_extensions.dart`)

```dart
// In any widget's build method:
context.theme          // ThemeData
context.colorScheme    // ColorScheme
context.textTheme      // TextTheme
context.screenWidth    // double
context.screenHeight   // double
context.isMobile       // width < 600
context.isTablet       // 600 <= width < 900
context.isDesktop      // width >= 900
context.showSnack('Saved!')  // Floating SnackBar
```

---

## 21. Responsive Design

### Breakpoints

| Width | Layout | Navigation |
|-------|--------|------------|
| < 600px | Mobile | Bottom NavigationBar |
| 600-900px | Tablet | NavigationRail (left side) |
| > 900px | Desktop | 240px Sidebar |

### Implementation

```dart
// adaptive_scaffold.dart
@override
Widget build(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;

  if (width >= 900) {
    return _buildDesktopLayout(child);    // Sidebar
  } else if (width >= 600) {
    return _buildTabletLayout(child);     // Rail
  } else {
    return _buildMobileLayout(child);     // Bottom bar
  }
}
```

### Navigation Destinations

All three layouts share the same 4 destinations:
1. Wallet (home icon)
2. Activities (list icon)
3. Dashboard (chart icon)
4. Settings (gear icon)

---

## 22. Firebase Setup

### Project Info

| Property | Value |
|----------|-------|
| Firebase Project | `chronos-flutt` |
| Hosting Site | `chronos-currency` |
| Web App ID | `1:526912592162:web:1bfe178662cca9d1132d7b` |

### Services Used

| Service | Purpose |
|---------|---------|
| Firebase Authentication | Email/password + Google sign-in |
| Cloud Firestore | User data & activity sync |
| Firebase Hosting | Web deployment (optional) |

### Configuration Files

| File | Purpose |
|------|---------|
| `firebase.json` | Hosting config (rewrites, caching) |
| `.firebaserc` | Project & target mapping |
| `firestore.indexes.json` | Firestore query indexes |
| `firestore.rules` | Security rules |
| `lib/firebase_options.dart` | Auto-generated platform config |

### Hosting Config (`firebase.json`)

```json
{
  "hosting": {
    "site": "chronos-currency",
    "public": "build/web",
    "rewrites": [
      { "source": "**", "destination": "/index.html" }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [{ "key": "Cache-Control", "value": "max-age=31536000" }]
      }
    ]
  }
}
```

---

## 23. CI/CD Pipelines

### Workflow: CI (`ci.yml`)

**Triggers:** PR to main/develop, push to develop

```yaml
Steps:
  1. Checkout code
  2. Setup Flutter 3.19.6 (with caching)
  3. flutter pub get
  4. dart format --set-exit-if-changed .
  5. flutter analyze --fatal-infos
  6. flutter test --coverage
```

### Workflow: Build (`build.yml`)

**Triggers:** Push to main, version tags (v*)

```yaml
Job 1 - Build Web:
  1. flutter build web --release --base-href "/Flutter.Mab/"
  2. Upload build/web as artifact

Job 2 - Build APK:
  1. Setup Java 17 (Temurin)
  2. flutter build apk --release
  3. Upload app-release.apk as artifact
```

### Workflow: Web Deploy (`web_deploy.yml`)

**Triggers:** Push to main, manual dispatch

```yaml
Steps:
  1. flutter build web --release --base-href "/Flutter.Mab/"
  2. Deploy to GitHub Pages via actions/deploy-pages@v4
```

---

## 24. Testing

### Test Structure

```
test/
├── core/
│   ├── extensions_test.dart          ← Date/duration formatting
│   └── models_test.dart              ← Model equality & copyWith
├── features/
│   ├── activity/
│   │   └── activity_bloc_test.dart   ← CRUD operations
│   ├── dashboard/
│   │   └── dashboard_bloc_test.dart  ← Weekly aggregation
│   ├── life_clock/
│   │   └── life_clock_bloc_test.dart ← Life calculation
│   ├── time_market/
│   │   └── trade_calculator_test.dart← Coin math
│   └── time_wallet/
│       └── time_wallet_bloc_test.dart← Budget state
```

### Testing Tools

| Tool | Purpose |
|------|---------|
| `flutter_test` | Widget & unit testing framework |
| `bloc_test` | `blocTest()` helper for BLoC testing |
| `mocktail` | Mock classes for dependencies |

### Example BLoC Test

```dart
blocTest<ActivityBloc, ActivityState>(
  'LoadActivities emits activities sorted by createdAt',
  build: () {
    when(() => mockRepo.getActivitiesForDate(any()))
        .thenReturn([activity1, activity2]);
    return ActivityBloc(mockRepo, mockStorage, mockSync);
  },
  act: (bloc) => bloc.add(const LoadActivities()),
  expect: () => [
    isA<ActivityState>()
        .having((s) => s.activities.length, 'count', 2)
        .having((s) => s.isLoading, 'loading', false),
  ],
);
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/activity/activity_bloc_test.dart
```

---

## 25. Key Architecture Decisions

### 1. Feature-First Clean Architecture

```
feature/
  ├── data/          ← Models, repositories (data layer)
  └── presentation/  ← BLoC, pages, widgets (UI layer)
```

**Why:** Each feature is self-contained. You can understand `activity/` without reading `dashboard/`.

### 2. BLoC for State Management

**Why BLoC over Provider/Riverpod:**
- Strict separation of events → logic → states
- Easy to test with `bloc_test`
- Predictable state flow (no surprise rebuilds)
- Mature ecosystem with good debugging tools

### 3. Offline-First with Hive

**Why:**
- App works 100% without internet
- No loading spinners for local data
- Instant response times
- Firestore sync is a bonus, not a requirement

### 4. GoRouter for Navigation

**Why:**
- Declarative routing (define routes as data)
- Built-in auth guards via `redirect`
- Auto-refresh on auth state changes
- Deep linking support for web

### 5. Immutable States with Equatable

**Why:**
- BLoC compares old vs new state to decide if UI should rebuild
- `Equatable` makes comparison efficient (no manual `==` override)
- `copyWith()` ensures you never accidentally mutate state

---

## 26. Quick Reference Table

| What | Where | Key |
|------|-------|-----|
| App entry point | `lib/main.dart` | `main()` |
| App widget | `lib/app.dart` | `ChronosApp` |
| Routes | `lib/core/router/app_router.dart` | `AppRouter.router()` |
| Auth logic | `lib/features/auth/presentation/bloc/auth_bloc.dart` | `AuthBloc` |
| Login screen | `lib/features/auth/presentation/pages/login_page.dart` | `LoginPage` |
| Signup screen | `lib/features/auth/presentation/pages/signup_page.dart` | `SignupPage` |
| Home screen | `lib/features/time_wallet/presentation/pages/time_wallet_page.dart` | `TimeWalletPage` |
| Activity list | `lib/features/activity/presentation/pages/activity_page.dart` | `ActivityPage` |
| Add activity | `lib/features/activity/presentation/pages/add_activity_page.dart` | `AddActivityPage` |
| Dashboard | `lib/features/dashboard/presentation/pages/dashboard_page.dart` | `DashboardPage` |
| Settings | `lib/features/settings/presentation/pages/settings_page.dart` | `SettingsPage` |
| Activity model | `lib/features/activity/data/models/activity_model.dart` | `ActivityModel` |
| Categories | `lib/core/constants/app_constants.dart` | `DefaultCategories.all` |
| Coin system | `lib/core/constants/rewards_config.dart` | `RewardsConfig` |
| Local storage | `lib/core/storage/storage_service.dart` | `StorageService` |
| Cloud sync | `lib/core/sync/firestore_sync_service.dart` | `FirestoreSyncService` |
| Firebase auth | `lib/core/auth/auth_repository.dart` | `AuthRepository` |
| Theme | `lib/core/theme/app_theme.dart` | `AppTheme.light()` / `.dark()` |
| Coach marks | `lib/core/help/coach_mark_service.dart` | `CoachMarkService` |
| Responsive nav | `lib/shared/widgets/adaptive_scaffold.dart` | `AdaptiveScaffold` |
| Life clock | `lib/features/life_clock/presentation/bloc/life_clock_bloc.dart` | `LifeClockBloc` |
| Extensions | `lib/core/extensions/date_extensions.dart` | `DateTime.formatted` etc. |

---

*Built with Flutter, Firebase, and the philosophy that your time is your most valuable currency.*
