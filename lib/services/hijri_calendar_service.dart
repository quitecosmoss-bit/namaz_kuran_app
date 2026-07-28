import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_exception.dart';

class IslamicEvent {
  final String name;
  final DateTime gregorianDate;
  final String hijriLabel;

  IslamicEvent({
    required this.name,
    required this.gregorianDate,
    required this.hijriLabel,
  });
}

class HijriCalendarService {
  static const _base = 'https://api.aladhan.com/v1';

  /// Hicri takvimde her yıl sabit gün/ay üzerinde tekrar eden dini günler
  /// (Diyanet'in kullandığı isimlerle).
  static const List<Map<String, dynamic>> _fixedEvents = [
    {'name': 'Hicri Yılbaşı (Muharrem)', 'month': 1, 'day': 1},
    {'name': 'Aşure Günü', 'month': 1, 'day': 10},
    {'name': 'Mevlid Kandili', 'month': 3, 'day': 12},
    {'name': 'Regaib Kandili', 'month': 7, 'day': 1},
    {'name': 'Mirac Kandili', 'month': 7, 'day': 27},
    {'name': 'Berat Kandili', 'month': 8, 'day': 15},
    {'name': 'Ramazan Başlangıcı', 'month': 9, 'day': 1},
    {'name': 'Kadir Gecesi', 'month': 9, 'day': 27},
    {'name': 'Ramazan Bayramı (1. Gün)', 'month': 10, 'day': 1},
    {'name': 'Ramazan Bayramı (2. Gün)', 'month': 10, 'day': 2},
    {'name': 'Ramazan Bayramı (3. Gün)', 'month': 10, 'day': 3},
    {'name': 'Kurban Bayramı (1. Gün)', 'month': 12, 'day': 10},
    {'name': 'Kurban Bayramı (2. Gün)', 'month': 12, 'day': 11},
    {'name': 'Kurban Bayramı (3. Gün)', 'month': 12, 'day': 12},
    {'name': 'Kurban Bayramı (4. Gün)', 'month': 12, 'day': 13},
  ];

  static const List<String> _hijriMonthNames = [
    'Muharrem',
    'Safer',
    'Rebiülevvel',
    'Rebiülahir',
    'Cemaziyelevvel',
    'Cemaziyelahir',
    'Recep',
    'Şaban',
    'Ramazan',
    'Şevval',
    'Zilkade',
    'Zilhicce',
  ];

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  Future<int> _hijriYearFor(DateTime gregorianDate) async {
    final r = await http.get(Uri.parse('$_base/gToH/${_fmt(gregorianDate)}'));
    if (r.statusCode != 200) throw AppException(AppErrorCode.network);
    final data = jsonDecode(r.body)['data']['hijri'];
    return int.parse(data['year'].toString());
  }

  Future<IslamicEvent?> _fetchEvent(
    Map<String, dynamic> event,
    int hijriYear,
    int targetGregorianYear,
  ) async {
    final hijriDateStr =
        '${event['day'].toString().padLeft(2, '0')}-${event['month'].toString().padLeft(2, '0')}-$hijriYear';
    try {
      final r = await http.get(Uri.parse('$_base/hToG/$hijriDateStr'));
      if (r.statusCode != 200) return null;
      final data = jsonDecode(r.body)['data']['gregorian'];
      final gDate = DateTime(
        int.parse(data['year'].toString()),
        int.parse(data['month']['number'].toString()),
        int.parse(data['day'].toString()),
      );
      if (gDate.year != targetGregorianYear) return null;
      return IslamicEvent(
        name: event['name'],
        gregorianDate: gDate,
        hijriLabel:
            '${event['day']} ${_hijriMonthNames[event['month'] - 1]} $hijriYear',
      );
    } catch (_) {
      return null;
    }
  }

  /// Verilen Miladi yıl içindeki tüm dini günleri, tarih sırasına göre
  /// sıralanmış şekilde döner.
  Future<List<IslamicEvent>> getYearEvents(int gregorianYear) async {
    int startHijriYear;
    int endHijriYear;
    try {
      startHijriYear = await _hijriYearFor(DateTime(gregorianYear, 1, 1));
      endHijriYear = await _hijriYearFor(DateTime(gregorianYear, 12, 31));
    } catch (_) {
      throw AppException(AppErrorCode.network);
    }

    final hijriYears = {startHijriYear, endHijriYear};

    final futures = <Future<IslamicEvent?>>[];
    for (final hy in hijriYears) {
      for (final e in _fixedEvents) {
        futures.add(_fetchEvent(e, hy, gregorianYear));
      }
    }

    final results = await Future.wait(futures);
    final events = results.whereType<IslamicEvent>().toList();
    events.sort((a, b) => a.gregorianDate.compareTo(b.gregorianDate));
    return events;
  }
}
