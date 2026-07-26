import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_exception.dart';
import '../models/prayer_times.dart';

class PrayerService {
  static const _baseUrl = 'https://api.aladhan.com/v1/timings';

  /// method=13 => Diyanet İşleri Başkanlığı (Türkiye) hesaplama yöntemi.
  Future<PrayerTimes> getTodayPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl?latitude=$latitude&longitude=$longitude&method=13',
    );

    final http.Response response;
    try {
      response = await http.get(uri);
    } catch (_) {
      throw AppException(AppErrorCode.network);
    }

    if (response.statusCode != 200) {
      throw AppException(AppErrorCode.network);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PrayerTimes.fromJson(data);
  }
}
