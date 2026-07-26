import 'package:flutter/foundation.dart';
import '../services/settings_service.dart';

/// Uygulamanın hem arayüz dilini hem de Kuran meal dilini kontrol eden
/// tek bir dil ayarı. Değiştiğinde tüm ekranlar otomatik güncellenir.
class AppSettings extends ChangeNotifier {
  final SettingsService _service = SettingsService();
  String _language = 'tr';
  bool _loaded = false;

  String get language => _language;
  bool get loaded => _loaded;

  Future<void> load() async {
    _language = await _service.getLanguage();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _language = code;
    await _service.setLanguage(code);
    notifyListeners();
  }
}
