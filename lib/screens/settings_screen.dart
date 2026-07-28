import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../providers/app_settings.dart';
import '../services/quran_service.dart';
import '../widgets/ad_banner_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettings>();
    final lang = appSettings.language;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('settingsTitle', lang))),
      bottomNavigationBar: const AdBannerWidget(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              AppStrings.get('settingsSectionTitle', lang),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              AppStrings.get('settingsSectionDesc', lang),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ...QuranService.languageLabels.entries.map((entry) {
            final code = entry.key;
            final label = entry.value;
            return RadioListTile<String>(
              value: code,
              groupValue: appSettings.language,
              title: Text(label),
              onChanged: (value) {
                if (value != null) {
                  appSettings.setLanguage(value);
                }
              },
            );
          }),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: AdBannerWidget(),
          ),
        ],
      ),
    );
  }
}
