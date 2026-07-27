import '../models/prayer_times.dart';

const Map<String, Map<String, String>> _weekdayTranslations = {
  'Monday': {'tr': 'Pazartesi', 'en': 'Monday', 'de': 'Montag', 'ru': 'Понедельник'},
  'Tuesday': {'tr': 'Salı', 'en': 'Tuesday', 'de': 'Dienstag', 'ru': 'Вторник'},
  'Wednesday': {'tr': 'Çarşamba', 'en': 'Wednesday', 'de': 'Mittwoch', 'ru': 'Среда'},
  'Thursday': {'tr': 'Perşembe', 'en': 'Thursday', 'de': 'Donnerstag', 'ru': 'Четверг'},
  'Friday': {'tr': 'Cuma', 'en': 'Friday', 'de': 'Freitag', 'ru': 'Пятница'},
  'Saturday': {'tr': 'Cumartesi', 'en': 'Saturday', 'de': 'Samstag', 'ru': 'Суббота'},
  'Sunday': {'tr': 'Pazar', 'en': 'Sunday', 'de': 'Sonntag', 'ru': 'Воскресенье'},
};

const Map<int, Map<String, String>> _monthTranslations = {
  1: {'tr': 'Ocak', 'en': 'January', 'de': 'Januar', 'ru': 'января'},
  2: {'tr': 'Şubat', 'en': 'February', 'de': 'Februar', 'ru': 'февраля'},
  3: {'tr': 'Mart', 'en': 'March', 'de': 'März', 'ru': 'марта'},
  4: {'tr': 'Nisan', 'en': 'April', 'de': 'April', 'ru': 'апреля'},
  5: {'tr': 'Mayıs', 'en': 'May', 'de': 'Mai', 'ru': 'мая'},
  6: {'tr': 'Haziran', 'en': 'June', 'de': 'Juni', 'ru': 'июня'},
  7: {'tr': 'Temmuz', 'en': 'July', 'de': 'Juli', 'ru': 'июля'},
  8: {'tr': 'Ağustos', 'en': 'August', 'de': 'August', 'ru': 'августа'},
  9: {'tr': 'Eylül', 'en': 'September', 'de': 'September', 'ru': 'сентября'},
  10: {'tr': 'Ekim', 'en': 'October', 'de': 'Oktober', 'ru': 'октября'},
  11: {'tr': 'Kasım', 'en': 'November', 'de': 'November', 'ru': 'ноября'},
  12: {'tr': 'Aralık', 'en': 'December', 'de': 'Dezember', 'ru': 'декабря'},
};

/// Bugünün tarihini, seçilen uygulama diline göre biçimlendirir.
/// Örn. tr: "Cumartesi, 25 Temmuz 2026", en: "Saturday, July 25, 2026"
String formatGregorianDate(PrayerTimes times, String lang) {
  final weekday =
      _weekdayTranslations[times.weekdayEn]?[lang] ?? times.weekdayEn;
  final month = _monthTranslations[times.gregorianMonth]?[lang] ?? '';
  final day = times.gregorianDay;
  final year = times.gregorianYear;

  switch (lang) {
    case 'en':
      return '$weekday, $month $day, $year';
    case 'de':
      return '$weekday, $day. $month $year';
    case 'ru':
      return '$weekday, $day $month $year г.';
    case 'tr':
    default:
      return '$weekday, $day $month $year';
  }
}
