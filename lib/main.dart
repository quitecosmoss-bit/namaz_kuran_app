import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_settings.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NamazKuranApp());
}

class NamazKuranApp extends StatelessWidget {
  const NamazKuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppSettings()..load(),
      child: MaterialApp(
        title: 'Namaz Vakitleri & Kuran',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
