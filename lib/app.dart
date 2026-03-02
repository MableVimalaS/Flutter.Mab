import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

class ChronosApp extends StatelessWidget {
  const ChronosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return MaterialApp.router(
          title: 'Chronos',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light().copyWith(
            textTheme: GoogleFonts.spaceGroteskTextTheme(
              AppTheme.light().textTheme,
            ),
          ),
          darkTheme: AppTheme.dark().copyWith(
            textTheme: GoogleFonts.spaceGroteskTextTheme(
              AppTheme.dark().textTheme,
            ),
          ),
          themeMode: state.themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
