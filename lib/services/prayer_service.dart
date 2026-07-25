import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_times.dart';

class PrayerService {
  static const _baseUrl = 'https://api.aladhan.com/v1/timings';

  /// method=13 => Diyanet İşleri Başkanlığı (Türkiye) hesaplama yöntemi.
  /// Aladhan API bu yöntemi resmi olarak destekliyor, böylece vakitler
  /// Diyanet'in yayınladığı vakitlerle aynı hesaplama mantığını kullanır.
  Future<PrayerTimes> getTodayPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl?latitude=$latitude&longitude=$longitude&method=13',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Namaz vakitleri alınamadı (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PrayerTimes.fromJson(data);
  }
}
