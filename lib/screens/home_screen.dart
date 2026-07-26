import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../providers/app_settings.dart';
import 'prayer_times_screen.dart';
import 'qibla_screen.dart';
import 'quran_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _screens = const [
    PrayerTimesScreen(),
    QiblaScreen(),
    QuranListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppSettings>().language;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.access_time),
            label: AppStrings.get('prayerTimesTitle', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: AppStrings.get('qiblaTitle', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book),
            label: AppStrings.get('navQuran', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppStrings.get('settingsTitle', lang),
          ),
        ],
      ),
    );
  }
}
