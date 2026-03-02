# Contributing to Chronos

First off, thank you for considering contributing to **Chronos**! Every contribution helps make this project better, and we truly appreciate your time (pun intended -- time *is* currency here).

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Branch Naming Convention](#branch-naming-convention)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Architecture Guidelines](#architecture-guidelines)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)

---

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior by opening an issue.

## How Can I Contribute?

- **Report bugs** using the [Bug Report](https://github.com/MableVimalaS/Flutter.Mab/issues/new?template=bug_report.md) template
- **Request features** using the [Feature Request](https://github.com/MableVimalaS/Flutter.Mab/issues/new?template=feature_request.md) template
- **Fix bugs** listed in [open issues](https://github.com/MableVimalaS/Flutter.Mab/issues?q=is%3Aopen+label%3Abug)
- **Implement features** tagged as [help wanted](https://github.com/MableVimalaS/Flutter.Mab/issues?q=is%3Aopen+label%3A%22help+wanted%22)
- **Improve documentation** -- typo fixes, better explanations, code samples
- **Write tests** to increase coverage

## Development Setup

### Prerequisites

| Tool       | Version  |
| ---------- | -------- |
| Flutter    | >= 3.24  |
| Dart       | >= 3.5   |
| Android Studio / VS Code | Latest |

### Getting Started

```bash
# 1. Fork and clone the repository
git clone https://github.com/<your-username>/Flutter.Mab.git
cd Flutter.Mab

# 2. Install dependencies
flutter pub get

# 3. Generate code (freezed, json_serializable, etc.)
dart run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run

# 5. Run tests
flutter test
```

### Useful Commands

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs

# Run tests with coverage
flutter test --coverage
```

## Branch Naming Convention

Use the following prefixes for your branches:

| Prefix       | Purpose                    | Example                        |
| ------------ | -------------------------- | ------------------------------ |
| `feature/`   | New features               | `feature/time-wallet-ui`       |
| `fix/`       | Bug fixes                  | `fix/budget-overflow-crash`    |
| `refactor/`  | Code refactoring           | `refactor/bloc-state-handling` |
| `docs/`      | Documentation updates      | `docs/update-readme`           |
| `test/`      | Adding or updating tests   | `test/wallet-bloc-unit-tests`  |
| `chore/`     | Build, CI, tooling changes | `chore/ci-coverage-threshold`  |

## Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short summary>

<optional body>

<optional footer>
```

### Types

| Type         | Description                           |
| ------------ | ------------------------------------- |
| `feat`       | A new feature                         |
| `fix`        | A bug fix                             |
| `docs`       | Documentation only changes            |
| `style`      | Formatting, missing semicolons, etc.  |
| `refactor`   | Code change that neither fixes a bug nor adds a feature |
| `test`       | Adding or correcting tests            |
| `chore`      | Build process, CI, auxiliary tools    |
| `perf`       | Performance improvements              |

### Examples

```
feat(wallet): add countdown timer to time wallet screen
fix(budget): resolve overflow when category exceeds 24h
docs(readme): add architecture diagram
test(dashboard): add widget tests for chart rendering
```

## Pull Request Process

1. **Create your branch** from `develop` (not `main`).
2. **Make your changes** following the coding standards below.
3. **Run all checks** before pushing:
   ```bash
   dart format .
   flutter analyze
   flutter test
   ```
4. **Push your branch** and open a Pull Request against `develop`.
5. **Fill out the PR template** completely.
6. **Request a review** and address any feedback.
7. Once approved, a maintainer will merge your PR.

## Coding Standards

### General

- Follow the [Effective Dart](https://dart.dev/effective-dart) guidelines.
- Use `dart format` for consistent formatting.
- Keep functions small and focused (single responsibility).
- Prefer immutable data -- use `freezed` for state and model classes.

### Naming

- **Files**: `snake_case.dart` (e.g., `time_wallet_bloc.dart`)
- **Classes**: `PascalCase` (e.g., `TimeWalletBloc`)
- **Variables/Functions**: `camelCase` (e.g., `remainingMinutes`)
- **Constants**: `camelCase` (e.g., `defaultBudgetMinutes`)
- **BLoC Events**: past tense (`TimeEntryAdded`, `BudgetUpdated`)
- **BLoC States**: adjective/status (`WalletLoaded`, `BudgetExceeded`)

### Folder Structure

Place new code in the appropriate feature folder following clean architecture:

```
lib/
  features/
    <feature_name>/
      data/           # Repositories, data sources, models
      domain/         # Entities, use cases, repository interfaces
      presentation/   # Screens, widgets, BLoC
```

### Testing

- Every new feature or bug fix should include tests.
- Place tests in a mirrored structure under `test/`.
- Aim for meaningful tests, not just coverage numbers.

## Architecture Guidelines

Chronos follows **feature-first clean architecture** with BLoC for state management:

- **Presentation layer** -- Widgets, Screens, and BLoC (events/states)
- **Domain layer** -- Entities, Use Cases, and Repository interfaces
- **Data layer** -- Repository implementations, local data sources (Hive), models

Key principles:
- Dependencies point inward (data -> domain <- presentation).
- The domain layer has **zero** dependencies on Flutter or external packages.
- Use `freezed` for all state classes, events, and entity models.
- Use `GoRouter` for declarative routing.

## Reporting Bugs

Use the **Bug Report** issue template and include:
- Steps to reproduce
- Expected vs. actual behavior
- Device info, OS version, Flutter version
- Logs or screenshots if possible

## Suggesting Features

Use the **Feature Request** issue template and describe:
- The problem your feature solves
- How it fits the "Time is Currency" concept
- A user story and any mockups if available

---

Thank you for helping make Chronos better! Every minute you invest in contributing is time well spent.
