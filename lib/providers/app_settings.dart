import 'package:flutter/foundation.dart';
import '../services/settings_service.dart';

/// Uygulamanın hem arayüz dilini hem de Kuran meal dilini kontrol eden
/// tek bir dil ayarı, ayrıca bildirim hatırlatma sürelerini de tutar.
class AppSettings extends ChangeNotifier {
  final SettingsService _service = SettingsService();
  String _language = 'tr';
  int _notifyMinutes1 = 60;
  int _notifyMinutes2 = 15;
  bool _loaded = false;

  String get language => _language;
  int get notifyMinutes1 => _notifyMinutes1;
  int get notifyMinutes2 => _notifyMinutes2;
  bool get loaded => _loaded;

  Future<void> load() async {
    _language = await _service.getLanguage();
    _notifyMinutes1 = await _service.getNotifyMinutes1();
    _notifyMinutes2 = await _service.getNotifyMinutes2();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _language = code;
    await _service.setLanguage(code);
    notifyListeners();
  }

  Future<void> setNotifyMinutes1(int minutes) async {
    _notifyMinutes1 = minutes;
    await _service.setNotifyMinutes1(minutes);
    notifyListeners();
  }

  Future<void> setNotifyMinutes2(int minutes) async {
    _notifyMinutes2 = minutes;
    await _service.setNotifyMinutes2(minutes);
    notifyListeners();
  }
}
