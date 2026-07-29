import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _languageKey = 'app_language';
  static const _notifyMinutes1Key = 'notify_minutes_1';
  static const _notifyMinutes2Key = 'notify_minutes_2';

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'tr';
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }

  Future<int> getNotifyMinutes1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_notifyMinutes1Key) ?? 60;
  }

  Future<void> setNotifyMinutes1(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notifyMinutes1Key, minutes);
  }

  Future<int> getNotifyMinutes2() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_notifyMinutes2Key) ?? 15;
  }

  Future<void> setNotifyMinutes2(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notifyMinutes2Key, minutes);
  }
}
