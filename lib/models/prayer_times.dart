class PrayerTimes {
  final String readableDate;
  final String hijriDate;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTimes({
    required this.readableDate,
    required this.hijriDate,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  /// Aladhan API "05:12 (+03)" gibi değerler dönebiliyor,
  /// sadece saat kısmını alıyoruz.
  static String _clean(String value) => value.split(' ').first;

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final timings = data['timings'] as Map<String, dynamic>;
    final date = data['date'] as Map<String, dynamic>;
    final hijri = date['hijri'] as Map<String, dynamic>;

    return PrayerTimes(
      readableDate: date['readable'] ?? '',
      hijriDate:
          '${hijri['day']} ${hijri['month']['en']} ${hijri['year']}',
      fajr: _clean(timings['Fajr'] ?? ''),
      sunrise: _clean(timings['Sunrise'] ?? ''),
      dhuhr: _clean(timings['Dhuhr'] ?? ''),
      asr: _clean(timings['Asr'] ?? ''),
      maghrib: _clean(timings['Maghrib'] ?? ''),
      isha: _clean(timings['Isha'] ?? ''),
    );
  }

  /// Ekranda liste halinde göstermek için kolay bir yapı
  List<MapEntry<String, String>> toDisplayList() {
    return [
      MapEntry('İmsak (Fajr)', fajr),
      MapEntry('Güneş', sunrise),
      MapEntry('Öğle', dhuhr),
      MapEntry('İkindi', asr),
      MapEntry('Akşam', maghrib),
      MapEntry('Yatsı', isha),
    ];
  }
}
