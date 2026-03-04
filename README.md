<h1 align="center">
  Chronos
</h1>

<p align="center">
  <strong>Time is Currency</strong> — Track your 24 hours like a budget.
</p>

<p align="center">
  Inspired by <em>"In Time"</em> (2011) — where every second counts.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.19-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.2+-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/State_Mgmt-BLoC-purple" alt="BLoC">
  <img src="https://img.shields.io/badge/Database-Hive-yellow" alt="Hive">
  <img src="https://img.shields.io/badge/Backend-Firebase-orange" alt="Firebase">
  <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License">
</p>

---

## The Concept

Chronos is a gamified time-tracking Flutter app inspired by the movie *In Time*.  
Instead of just tracking tasks, Chronos treats your **24 hours as currency**.

Spend time wisely, earn **Time Coins**, level up, and watch your **Life Clock** change based on your habits.

---

# 🚀 Features

## ⏱ Time Wallet

Track your daily time usage like a financial wallet.

- Daily time budget
- Real-time countdown ring
- Activity tracking
- Time spent vs remaining

---

## 🪙 Time Coins & Gamification

Good habits earn rewards while bad habits cost you.

Habit | Coins
--- | ---
Exercise | +10 coins
Learning | +10 coins
Work | +5 coins
Scrolling | 0 coins
Smoking | -11 coins

Coins unlock levels and bonus life days.

---

## ❤️ Life Clock

A real-time countdown of your life.

Based on:

- Date of birth
- Habit quality
- Coins earned
- Penalties from bad habits

Remaining Life  
YRS : MOS : DAYS : HRS : MIN : SEC

---

## 📊 Dashboard Analytics

Visualize how you spend time.

- Weekly activity charts
- Category breakdown
- Streak tracking
- Trade quality analysis

---

## ☁️ Cloud Sync

Chronos works **offline-first** but syncs with the cloud.

- Local storage via Hive
- Cloud sync with Firebase Firestore
- Secure authentication via Firebase Auth

---

## 📱 Cross Platform

Built with Flutter.

Runs on:

- Android
- iOS
- Web
- Desktop

---

# 🏗 Architecture

Chronos follows a **feature-first clean architecture using the BLoC pattern**.

lib/
 ├── core/
 │    ├── auth
 │    ├── router
 │    ├── storage
 │    ├── sync
 │    └── theme
 │
 ├── features/
 │    ├── activity
 │    ├── auth
 │    ├── dashboard
 │    ├── life_clock
 │    ├── onboarding
 │    ├── settings
 │    ├── time_market
 │    └── time_wallet
 │
 └── shared/
      └── widgets

Key principles:

- Offline-first design
- Separation of UI and business logic
- Modular feature architecture
- Predictable state management

---

# 🛠 Tech Stack

Technology | Purpose
--- | ---
Flutter | Cross-platform UI framework
Dart | Programming language
flutter_bloc | State management
GoRouter | Navigation & routing
Hive | Local database
Firebase Auth | Authentication
Cloud Firestore | Cloud database
fl_chart | Analytics charts
Google Fonts | Typography

---

# 🔐 Authentication

Chronos supports:

- Email & Password
- Google Sign-In
- Secure session persistence

---

# 📊 Gamification System

Level | Coins | Bonus Life
--- | --- | ---
Time Beginner | 0 | 0 days
Time Saver | 100 | +7 days
Time Investor | 500 | +30 days
Time Master | 1500 | +90 days
Time Millionaire | 5000 | +180 days

---

# 📦 Installation

1️⃣ Clone the repository

git clone https://github.com/yourusername/chronos.git  
cd chronos

2️⃣ Install dependencies

flutter pub get

3️⃣ Run the app

flutter run

---

# 🔥 Firebase Setup

Create a Firebase project and enable:

- Authentication
- Firestore
- Hosting (optional)

Then run:

flutterfire configure

---

# 🧪 Testing

Run all tests:

flutter test

Coverage:

flutter test --coverage

---

# 📈 Future Improvements

- AI habit recommendations
- Time trading marketplace
- Smart productivity insights
- Wearable integration
- Calendar sync

---

# 🎬 Inspiration

Inspired by the movie **In Time (2011)** where **time is the world's currency**.

Chronos brings that philosophy into **daily productivity**.

---

# 🤝 Contributing

Pull requests are welcome.

Steps:

1. Fork the repository
2. Create a new branch
3. Commit your changes
4. Open a pull request

---

# 📜 License

MIT License

---

# ⭐ If you like this project

Give it a star ⭐ on GitHub.

---

👩‍💻 Built with Flutter

Chronos demonstrates:

- Clean Flutter architecture
- Advanced BLoC usage
- Offline-first design
- Gamified productivity systems
