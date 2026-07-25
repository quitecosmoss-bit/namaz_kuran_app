import 'package:flutter/foundation.dart';
import '../services/settings_service.dart';

class AppSettings extends ChangeNotifier {
  final SettingsService _service = SettingsService();
  String _mealLanguage = 'tr';
  bool _loaded = false;

  String get mealLanguage => _mealLanguage;
  bool get loaded => _loaded;

  Future<void> load() async {
    _mealLanguage = await _service.getMealLanguage();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setMealLanguage(String code) async {
    _mealLanguage = code;
    await _service.setMealLanguage(code);
    notifyListeners();
  }
}
