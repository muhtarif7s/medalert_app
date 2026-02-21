import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/add_edit_medicine_screen.dart';
import 'screens/medicine_detail_screen.dart';
import 'screens/missed_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/add', builder: (c, s) => const AddEditMedicineScreen()),
      GoRoute(path: '/med/:id', builder: (c, s) {
        final id = int.tryParse(s.params['id'] ?? '0') ?? 0;
        return MedicineDetailScreen(medicineId: id);
      }),
      GoRoute(path: '/missed', builder: (c, s) => const MissedScreen()),
      GoRoute(path: '/history', builder: (c, s) => const HistoryScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
    ]);

    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'MediMate',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal, brightness: Brightness.dark),
      themeMode: themeMode,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
    );
  }
}
