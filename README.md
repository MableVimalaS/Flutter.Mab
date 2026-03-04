<h1 align="center">
  Chronos
</h1>

<p align="center">
  <strong>Time is Currency</strong> — Track your 24 daily hours like a budget.
</p>

<p align="center">
  Inspired by <em>"In Time"</em> (2011) — where every second counts.
</p>

<p align="center">
  <a href="https://github.com/MableVimalaS/Flutter.Mab/actions/workflows/ci.yml"><img src="https://github.com/MableVimalaS/Flutter.Mab/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://github.com/MableVimalaS/Flutter.Mab/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
  <img src="https://img.shields.io/badge/Flutter-3.19-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.2+-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/State_Mgmt-BLoC-purple" alt="BLoC">
</p>

---

## The Concept

Your **24 hours** are the most valuable currency you own. Chronos helps you track where every minute goes — just like tracking expenses, but for time.

- Log activities throughout your day
- Set daily time budgets (awake hours)
- See beautiful charts of your time distribution
- Build streaks for consistent tracking
- Works completely offline

## Screenshots

> *Coming soon — screenshots of the Time Wallet, Activity Log, and Dashboard screens.*

## Features

| Feature | Description |
|---------|-------------|
| **Time Wallet** | Animated countdown ring showing remaining daily time |
| **Activity Logging** | Quick-tap categories with duration slider |
| **Dashboard** | Weekly bar charts, pie charts, category breakdowns |
| **Streaks** | Track consecutive days of activity logging |
| **Time Budgets** | Set your daily awake hours (8-20h) |
| **Dark Mode** | Full light/dark/system theme support |
| **Adaptive Layout** | Phone (bottom nav), tablet (rail), desktop (sidebar) |
| **Onboarding** | 3-page animated intro explaining the concept |
| **Offline-First** | All data stored locally with Hive |

## Tech Stack

| Category | Package | Purpose |
|----------|---------|---------|
| State Management | `flutter_bloc` | BLoC pattern for reactive state |
| Navigation | `go_router` | Declarative routing + deep linking |
| Local Storage | `hive` + `hive_flutter` | Fast NoSQL offline database |
| Charts | `fl_chart` | Animated bar/pie charts |
| Animation | `flutter_animate` | Fluid widget animations |
| UI | Material 3 + `google_fonts` | Dynamic theming with Space Grotesk |
| Utilities | `equatable`, `uuid`, `intl` | Data classes, IDs, formatting |
| Testing | `bloc_test` + `mocktail` | BLoC tests with mocking |

## Architecture

Feature-first clean architecture with BLoC pattern:

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp.router config
├── core/
│   ├── constants/app_constants.dart   # Categories, breakpoints
│   ├── extensions/                    # Context, date, duration helpers
│   ├── error/failures.dart            # Error types
│   ├── router/app_router.dart         # GoRouter + ShellRoute
│   ├── storage/storage_service.dart   # Hive wrapper
│   └── theme/app_theme.dart           # Light/dark Material 3 themes
├── features/
│   ├── time_wallet/                   # Home screen — countdown ring
│   ├── activity/                      # Activity logging & list
│   ├── dashboard/                     # Charts & weekly stats
│   ├── settings/                      # Theme, budget, data mgmt
│   └── onboarding/                    # 3-page intro flow
└── shared/
    └── widgets/                       # GlassCard, StatChip, AdaptiveScaffold
```

Each feature follows: `data/ → domain/ → presentation/bloc/ + pages/ + widgets/`

## Getting Started

### Prerequisites

- Flutter SDK >= 3.19.0
- Dart SDK >= 3.2.0

### Installation

```bash
# Clone the repository
git clone https://github.com/MableVimalaS/Flutter.Mab.git
cd Flutter.Mab

# Create platform files (if not present)
flutter create . --project-name chronos --org com.mablevimalas

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Running Tests

```bash
flutter test
```

## Categories

Chronos comes with 12 built-in time categories:

| Category | Icon | Color |
|----------|------|-------|
| Work | Briefcase | Indigo |
| Exercise | Dumbbell | Green |
| Learning | Graduation | Amber |
| Social | People | Red |
| Commute | Car | Blue Grey |
| Meals | Restaurant | Deep Orange |
| Entertainment | Movie | Purple |
| Self Care | Spa | Cyan |
| Chores | Cleaning | Brown |
| Creative | Palette | Pink |
| Scrolling | Phone | Red |
| Other | More | Grey |

## Contributing

Contributions are welcome! Please read the [Contributing Guide](CONTRIBUTING.md) before submitting a PR.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Built with Flutter | Inspired by <em>"In Time"</em> (2011)
</p>
