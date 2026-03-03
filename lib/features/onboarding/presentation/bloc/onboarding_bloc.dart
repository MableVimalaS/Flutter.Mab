import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/storage_service.dart';

// --- Events ---

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class CheckOnboarding extends OnboardingEvent {
  const CheckOnboarding();
}

class CompleteOnboarding extends OnboardingEvent {
  const CompleteOnboarding();
}

class NextPage extends OnboardingEvent {
  const NextPage();
}

class PreviousPage extends OnboardingEvent {
  const PreviousPage();
}

class SetAuthComplete extends OnboardingEvent {
  const SetAuthComplete();
}

class GoToPage extends OnboardingEvent {
  const GoToPage(this.page);

  final int page;

  @override
  List<Object?> get props => [page];
}

class SetDateOfBirth extends OnboardingEvent {
  const SetDateOfBirth(this.dateOfBirth);

  final DateTime dateOfBirth;

  @override
  List<Object?> get props => [dateOfBirth];
}

// --- State ---

class OnboardingState extends Equatable {
  const OnboardingState({
    this.hasCompleted = false,
    this.currentPage = 0,
    this.isLoading = true,
    this.isAuthComplete = false,
    this.dateOfBirth,
  });

  final bool hasCompleted;
  final int currentPage;
  final bool isLoading;
  final bool isAuthComplete;
  final DateTime? dateOfBirth;

  /// Total pages: 0-2 intro, 3 auth, 4 DOB
  static const int totalPages = 5;

  OnboardingState copyWith({
    bool? hasCompleted,
    int? currentPage,
    bool? isLoading,
    bool? isAuthComplete,
    DateTime? dateOfBirth,
  }) {
    return OnboardingState(
      hasCompleted: hasCompleted ?? this.hasCompleted,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      isAuthComplete: isAuthComplete ?? this.isAuthComplete,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  @override
  List<Object?> get props => [
        hasCompleted,
        currentPage,
        isLoading,
        isAuthComplete,
        dateOfBirth,
      ];
}

// --- BLoC ---

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc(this._storage) : super(const OnboardingState()) {
    on<CheckOnboarding>(_onCheck);
    on<CompleteOnboarding>(_onComplete);
    on<NextPage>(_onNext);
    on<PreviousPage>(_onPrevious);
    on<GoToPage>(_onGoToPage);
    on<SetAuthComplete>(_onSetAuthComplete);
    on<SetDateOfBirth>(_onSetDateOfBirth);
  }

  final StorageService _storage;

  Future<void> _onCheck(
    CheckOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    final completed = _storage.hasCompletedOnboarding;
    emit(
      state.copyWith(hasCompleted: completed, isLoading: false),
    );
  }

  Future<void> _onComplete(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    await _storage.completeOnboarding();
    emit(state.copyWith(hasCompleted: true));
  }

  void _onNext(NextPage event, Emitter<OnboardingState> emit) {
    // Block at page 3 (auth) if not authenticated
    if (state.currentPage == 3 && !state.isAuthComplete) return;

    // Block at page 4 (DOB) if no DOB set
    if (state.currentPage == 4 && state.dateOfBirth == null) return;

    if (state.currentPage < OnboardingState.totalPages - 1) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  void _onPrevious(PreviousPage event, Emitter<OnboardingState> emit) {
    if (state.currentPage > 0) {
      emit(state.copyWith(currentPage: state.currentPage - 1));
    }
  }

  void _onGoToPage(GoToPage event, Emitter<OnboardingState> emit) {
    final page = event.page.clamp(0, OnboardingState.totalPages - 1);
    emit(state.copyWith(currentPage: page));
  }

  void _onSetAuthComplete(
    SetAuthComplete event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(isAuthComplete: true));
  }

  Future<void> _onSetDateOfBirth(
    SetDateOfBirth event,
    Emitter<OnboardingState> emit,
  ) async {
    await _storage.setDateOfBirth(event.dateOfBirth);
    emit(state.copyWith(dateOfBirth: event.dateOfBirth));
  }
}
