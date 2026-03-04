cat << 'EOF' > README.md
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
  <img src="https://img.shields.io/badge/Database-Hive-yellow" alt="Hive">
  <img src="https://img.shields.io/badge/Backend-Firebase-orange" alt="Firebase">
</p>

---

## The Concept

Your **24 hours** are the most valuable currency you own. Chronos helps you track where every minute goes — just like tracking expenses, but for time.

Instead of just logging tasks, Chronos **gamifies your daily life**:

- Spend time like currency
- Earn **Time Coins** from productive habits
- Lose coins for unhealthy habits
- Visualize your life through a **real-time Life Clock**

---

## Screenshots

Coming soon — previews of the Time Wallet, Activity Log, Life Clock, and Dashboard.

---

## Features

| Feature | Description |
|--------|-------------|
| Time Wallet | Animated countdown ring showing remaining daily time |
| Activity Logging | Quick category selection with duration slider |
| Life Clock | Real-time countdown of your remaining life |
| Time Coins | Earn coins from productive habits |
| Levels System | Level up and gain bonus life days |
| Dashboard Analytics | Weekly charts and category insights |
| Streak Tracking | Track consistent productivity habits |
| Time Budgets | Configure daily awake hours |
| Cloud Sync | Sync activities across devices with Firebase |
| Offline-First | Works fully offline using Hive database |
| Adaptive Layout | Mobile, tablet, and desktop navigation |
| Dark Mode | Light / Dark / System theme support |

---

## Tech Stack

| Category | Package | Purpose |
|----------|---------|---------|
| UI Framework | Flutter | Cross-platform UI |
| Language | Dart | Programming language |
| State Management | flutter_bloc | BLoC architecture |
| Navigation | go_router | Declarative routing |
| Local Storage | hive | Fast offline NoSQL DB |
| Backend | Firebase Auth | Authentication |
| Database | Firestore | Cloud sync |
| Charts | fl_chart | Data visualization |
| Animations | flutter_animate | UI animations |
| Fonts | google_fonts | Space Grotesk typography |

---

## Architecture

lib/
├── main.dart  
├── app.dart  
├── core/  
├── features/  
│   ├── time_wallet/  
│   ├── activity/  
│   ├── dashboard/  
│   ├── life_clock/  
│   ├── settings/  
│   └── onboarding/  
└── shared/widgets/

---

## Installation

git clone https://github.com/MableVimalaS/Flutter.Mab.git  
cd Flutter.Mab  
flutter pub get  
flutter run

---

## License

MIT License

---

<p align="center">
  Built with Flutter | Inspired by <em>"In Time"</em> (2011)
</p>

EOF
