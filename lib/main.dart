import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/hive_local_datasource.dart';
import 'presentation/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final hiveLocalDatasource = HiveLocalDatasource();
  await hiveLocalDatasource.init();
  await hiveLocalDatasource.seedWordsFromAssets();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }
  runApp(
    ProviderScope(
      overrides: [
        hiveLocalDatasourceProvider.overrideWithValue(hiveLocalDatasource),
      ],
      child: const AmirentApp(),
    ),
  );
}

class AmirentApp extends ConsumerWidget {
  const AmirentApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp.router(
      title: 'Amirent Smart Trainer',
      debugShowCheckedModeBanner: false,
      locale: const Locale('he', 'IL'),
      supportedLocales: const [Locale('he', 'IL'), Locale('en', 'US')],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
    );
  }
}
