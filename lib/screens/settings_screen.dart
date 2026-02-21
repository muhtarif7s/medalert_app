import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        const ListTile(title: Text('Profile')),
        SwitchListTile(
          title: const Text('Use Arabic (RTL)'),
          value: locale?.languageCode == 'ar',
          onChanged: (v) => ref.read(localeProvider.notifier).state = v ? const Locale('ar') : null,
        ),
        ListTile(title: const Text('Notifications')),
        ListTile(
          title: const Text('Appearance'),
          subtitle: Text(themeMode == ThemeMode.system ? 'System' : themeMode == ThemeMode.dark ? 'Dark' : 'Light'),
          trailing: PopupMenuButton<ThemeMode>(
            onSelected: (m) => ref.read(themeModeProvider.notifier).state = m,
            itemBuilder: (c) => [
              const PopupMenuItem(value: ThemeMode.system, child: Text('System')),
              const PopupMenuItem(value: ThemeMode.light, child: Text('Light')),
              const PopupMenuItem(value: ThemeMode.dark, child: Text('Dark')),
            ],
          ),
        ),
        const ListTile(title: Text('Security')),
      ]),
    );
  }
}
