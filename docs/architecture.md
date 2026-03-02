# Chronos Architecture

## Overview

Chronos follows **feature-first clean architecture** with the **BLoC pattern** for state management. The app is structured to keep features self-contained while sharing common infrastructure through the `core/` and `shared/` layers.

## Layers

```
┌─────────────────────────────────────────┐
│            Presentation Layer           │
│   (Pages, Widgets, BLoC Events/States)  │
├─────────────────────────────────────────┤
│              Domain Layer               │
│       (Entities, Repository Interfaces) │
├─────────────────────────────────────────┤
│               Data Layer                │
│   (Repository Impl, Models, Storage)    │
└─────────────────────────────────────────┘
```

### Presentation
- Flutter widgets and pages
- BLoC classes handle all business logic
- Events trigger state changes
- UI rebuilds reactively via `BlocBuilder`

### Domain
- Pure Dart entities (no Flutter dependencies)
- Repository interfaces (contracts)

### Data
- Hive models with TypeAdapters
- Repository implementations
- StorageService wraps Hive operations

## State Management: BLoC

Each feature has its own BLoC:

| BLoC | Responsibility |
|------|---------------|
| `TimeWalletBloc` | Today's time balance, remaining minutes, streak |
| `ActivityBloc` | CRUD operations on activities, date filtering |
| `DashboardBloc` | Weekly stats, chart data computation |
| `SettingsBloc` | Theme mode, daily budget, data management |
| `OnboardingBloc` | First-launch flow state |

All BLoCs are provided at the app root via `MultiBlocProvider` in `main.dart`.

## Navigation

Uses `go_router` with a `ShellRoute` for the main scaffold:

```
/onboarding     → OnboardingPage
/wallet         → TimeWalletPage    (ShellRoute)
/activities     → ActivityPage      (ShellRoute)
/dashboard      → DashboardPage     (ShellRoute)
/settings       → SettingsPage      (ShellRoute)
/add-activity   → AddActivityPage   (modal route)
```

The `AdaptiveScaffold` widget wraps ShellRoute children and switches between:
- **Mobile** (< 600px): Bottom NavigationBar
- **Tablet** (600-1200px): NavigationRail
- **Desktop** (> 1200px): Sidebar with drawer

## Storage

All data is stored locally using Hive:

| Box | Type | Purpose |
|-----|------|---------|
| `activities` | `Box<ActivityModel>` | All logged time activities |
| `settings` | `Box<dynamic>` | Theme mode, budget, onboarding flag |

`StorageService` provides a clean API over raw Hive box operations.

## Theming

Material 3 dynamic theming with `ColorScheme.fromSeed()`:
- **Seed color**: Cyan (`#00E5FF`) — futuristic, matches the time/tech theme
- **Dark mode**: Deep navy background (`#0A0E21`)
- **Font**: Space Grotesk (via Google Fonts)
- **Theme mode**: System / Light / Dark (persisted in Hive)
