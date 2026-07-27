class PrayerTimes {
  final int gregorianDay;
  final int gregorianMonth;
  final int gregorianYear;
  final String weekdayEn; // "Saturday" gibi, İngilizce - kendi sözlüğümüzde çeviriyoruz
  final String hijriDate;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTimes({
    required this.gregorianDay,
    required this.gregorianMonth,
    required this.gregorianYear,
    required this.weekdayEn,
    required this.hijriDate,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  static String _clean(String value) => value.split(' ').first;

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final timings = data['timings'] as Map<String, dynamic>;
    final date = data['date'] as Map<String, dynamic>;
    final hijri = date['hijri'] as Map<String, dynamic>;
    final gregorian = date['gregorian'] as Map<String, dynamic>;

    return PrayerTimes(
      gregorianDay: int.parse(gregorian['day'].toString()),
      gregorianMonth: int.parse(gregorian['month']['number'].toString()),
      gregorianYear: int.parse(gregorian['year'].toString()),
      weekdayEn: gregorian['weekday']?['en'] ?? '',
      hijriDate: '${hijri['day']} ${hijri['month']['en']} ${hijri['year']}',
      fajr: _clean(timings['Fajr'] ?? ''),
      sunrise: _clean(timings['Sunrise'] ?? ''),
      dhuhr: _clean(timings['Dhuhr'] ?? ''),
      asr: _clean(timings['Asr'] ?? ''),
      maghrib: _clean(timings['Maghrib'] ?? ''),
      isha: _clean(timings['Isha'] ?? ''),
    );
  }
}
