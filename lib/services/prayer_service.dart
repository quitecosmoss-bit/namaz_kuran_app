import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_exception.dart';
import '../models/prayer_times.dart';

class PrayerService {
  static const _baseUrl = 'https://api.aladhan.com/v1/timings';
  static const _calendarUrl = 'https://api.aladhan.com/v1/calendar';

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

  /// Bugünden başlayarak önümüzdeki [daysAhead] günün namaz vakitlerini
  /// getirir. Aladhan'ın "calendar" uç noktası tek istekte bir ayın tüm
  /// günlerini döndürdüğü için (günlük tek tek istek atmak yerine) ay
  /// sınırını aşan durumlarda bir sonraki ayı da otomatik çeker.
  ///
  /// Bu, bildirimlerin sadece "bugün için" değil, uygulama günlerce hiç
  /// açılmasa bile önceden planlanmış olarak çalışabilmesini sağlamak
  /// içindir - bkz. NotificationService.scheduleForUpcomingDays.
  Future<List<PrayerTimes>> getUpcomingPrayerTimes({
    required double latitude,
    required double longitude,
    int daysAhead = 30,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final results = <PrayerTimes>[];

    var year = now.year;
    var month = now.month;
    var safetyCounter = 0;

    while (results.length < daysAhead && safetyCounter < 3) {
      final monthDays = await _getCalendarMonth(
        latitude: latitude,
        longitude: longitude,
        year: year,
        month: month,
      );

      for (final pt in monthDays) {
        final date = DateTime(pt.gregorianYear, pt.gregorianMonth, pt.gregorianDay);
        if (!date.isBefore(today)) {
          results.add(pt);
        }
      }

      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
      safetyCounter++;
    }

    return results.take(daysAhead).toList();
  }

  Future<List<PrayerTimes>> _getCalendarMonth({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  }) async {
    final uri = Uri.parse(
      '$_calendarUrl?latitude=$latitude&longitude=$longitude&method=13&month=$month&year=$year',
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
    final list = data['data'] as List<dynamic>;
    return list
        .map((item) => PrayerTimes.fromJson({'data': item}))
        .toList();
  }
}
