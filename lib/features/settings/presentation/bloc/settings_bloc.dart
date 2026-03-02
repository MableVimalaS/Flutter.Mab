import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/storage_service.dart';

// --- Events ---

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class ChangeThemeMode extends SettingsEvent {
  const ChangeThemeMode(this.mode);

  final ThemeMode mode;

  @override
  List<Object?> get props => [mode];
}

class ChangeDailyBudget extends SettingsEvent {
  const ChangeDailyBudget(this.hours);

  final int hours;

  @override
  List<Object?> get props => [hours];
}

class ClearAllData extends SettingsEvent {
  const ClearAllData();
}

// --- State ---

class SettingsState extends Equatable {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.dailyBudgetHours = 16,
    this.isLoading = true,
  });

  final ThemeMode themeMode;
  final int dailyBudgetHours;
  final bool isLoading;

  SettingsState copyWith({
    ThemeMode? themeMode,
    int? dailyBudgetHours,
    bool? isLoading,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      dailyBudgetHours: dailyBudgetHours ?? this.dailyBudgetHours,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [themeMode, dailyBudgetHours, isLoading];
}

// --- BLoC ---

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._storage) : super(const SettingsState()) {
    on<LoadSettings>(_onLoad);
    on<ChangeThemeMode>(_onChangeTheme);
    on<ChangeDailyBudget>(_onChangeBudget);
    on<ClearAllData>(_onClearData);
  }

  final StorageService _storage;

  Future<void> _onLoad(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final modeString = _storage.themeMode;
    final mode = switch (modeString) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final budget = _storage.dailyHoursBudget;

    emit(
      state.copyWith(
        themeMode: mode,
        dailyBudgetHours: budget,
        isLoading: false,
      ),
    );
  }

  Future<void> _onChangeTheme(
    ChangeThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    final modeString = switch (event.mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await _storage.setThemeMode(modeString);
    emit(state.copyWith(themeMode: event.mode));
  }

  Future<void> _onChangeBudget(
    ChangeDailyBudget event,
    Emitter<SettingsState> emit,
  ) async {
    await _storage.setDailyHoursBudget(event.hours);
    emit(state.copyWith(dailyBudgetHours: event.hours));
  }

  Future<void> _onClearData(
    ClearAllData event,
    Emitter<SettingsState> emit,
  ) async {
    await _storage.clearAllData();
  }
}
