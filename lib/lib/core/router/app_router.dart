import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/study/study_screen.dart';
import '../../presentation/screens/games/games_screen.dart';
import '../../presentation/screens/statistics/statistics_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const study = '/study';
  static const games = '/games';
  static const statistics = '/statistics';
  static const settings = '/settings';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.study,
      builder: (context, state) {
        final sessionType = state.uri.queryParameters['type'] ?? 'daily';
        return StudyScreen(sessionType: sessionType);
      },
    ),
    GoRoute(
      path: AppRoutes.games,
      builder: (context, state) => const GamesScreen(),
    ),
    GoRoute(
      path: AppRoutes.statistics,
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
