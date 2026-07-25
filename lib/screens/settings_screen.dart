import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings.dart';
import '../services/quran_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettings>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Kuran meal dili',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'Sure okurken Arapça orijinal metnin yanında hangi dildeki '
              'meali görmek istersin?',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ...QuranService.languageLabels.entries.map((entry) {
            final code = entry.key;
            final label = entry.value;
            return RadioListTile<String>(
              value: code,
              groupValue: appSettings.mealLanguage,
              title: Text(label),
              onChanged: (value) {
                if (value != null) {
                  appSettings.setMealLanguage(value);
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
