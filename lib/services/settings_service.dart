import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _languageKey = 'meal_language';

  Future<String> getMealLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'tr';
  }

  Future<void> setMealLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }
}
