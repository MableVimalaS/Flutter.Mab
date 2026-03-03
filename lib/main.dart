import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/storage/storage_service.dart';
import 'features/activity/data/models/activity_model.dart';
import 'features/activity/data/models/time_category_model.dart';
import 'features/activity/data/repositories/activity_repository_impl.dart';
import 'features/activity/presentation/bloc/activity_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/life_clock/presentation/bloc/life_clock_bloc.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/time_wallet/presentation/bloc/time_wallet_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ActivityModelAdapter());
  Hive.registerAdapter(TimeCategoryModelAdapter());

  final storageService = StorageService();
  await storageService.init();

  final activityRepository = ActivityRepositoryImpl(storageService);

  runApp(
    RepositoryProvider.value(
      value: storageService,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => TimeWalletBloc(activityRepository, storageService)
              ..add(const LoadTimeWallet()),
          ),
          BlocProvider(
            create: (_) => ActivityBloc(activityRepository, storageService)
              ..add(const LoadActivities()),
          ),
          BlocProvider(
            create: (_) =>
                DashboardBloc(activityRepository)..add(const LoadDashboard()),
          ),
          BlocProvider(
            create: (_) =>
                SettingsBloc(storageService)..add(const LoadSettings()),
          ),
          BlocProvider(
            create: (_) =>
                LifeClockBloc(storageService)..add(const LoadLifeClock()),
          ),
          BlocProvider(
            create: (_) =>
                OnboardingBloc(storageService)..add(const CheckOnboarding()),
          ),
        ],
        child: const ChronosApp(),
      ),
    ),
  );
}
