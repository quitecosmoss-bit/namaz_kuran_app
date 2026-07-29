import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../localization/notification_durations.dart';
import '../providers/app_settings.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickDuration({
    required BuildContext context,
    required String title,
    required int currentValue,
    required String lang,
    required ValueChanged<int> onSelected,
  }) async {
    final selected = await showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(title),
          children: notificationDurationPresets.map((minutes) {
            return RadioListTile<int>(
              value: minutes,
              groupValue: currentValue,
              title: Text(notificationDurationLabel(minutes, lang)),
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        );
      },
    );
    if (selected != null) {
      onSelected(selected);
    }
  }

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

          const Divider(height: 32),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              AppStrings.get('notifSettingsTitle', lang),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              AppStrings.get('notifSettingsDesc', lang),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.notifications_active,
                  color: AppTheme.primaryGreen),
              title: Text(
                AppStrings.get('notifTitle1', lang),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Text(
                notificationDurationLabel(appSettings.notifyMinutes1, lang),
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _pickDuration(
                context: context,
                title: AppStrings.get('notifTitle1', lang),
                currentValue: appSettings.notifyMinutes1,
                lang: lang,
                onSelected: appSettings.setNotifyMinutes1,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading:
                  const Icon(Icons.water_drop, color: AppTheme.primaryGreen),
              title: Text(
                AppStrings.get('notifTitle2', lang),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Text(
                notificationDurationLabel(appSettings.notifyMinutes2, lang),
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _pickDuration(
                context: context,
                title: AppStrings.get('notifTitle2', lang),
                currentValue: appSettings.notifyMinutes2,
                lang: lang,
                onSelected: appSettings.setNotifyMinutes2,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: AdBannerWidget(),
          ),
        ],
      ),
    );
  }
}
