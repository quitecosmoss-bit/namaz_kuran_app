/// Kullanıcının seçebileceği hazır süre seçenekleri (dakika cinsinden).
/// Hazır bir liste kullanmak, her sayı için doğru dilbilgisi çekimini
/// (özellikle Rusça'da) elle ve güvenli şekilde tanımlamamızı sağlıyor.
const List<int> notificationDurationPresets = [5, 10, 15, 20, 30, 45, 60, 90, 120];

const Map<int, Map<String, String>> notificationDurationLabels = {
  5: {'tr': '5 dakika', 'en': '5 minutes', 'de': '5 Minuten', 'ru': '5 минут'},
  10: {
    'tr': '10 dakika',
    'en': '10 minutes',
    'de': '10 Minuten',
    'ru': '10 минут',
  },
  15: {
    'tr': '15 dakika',
    'en': '15 minutes',
    'de': '15 Minuten',
    'ru': '15 минут',
  },
  20: {
    'tr': '20 dakika',
    'en': '20 minutes',
    'de': '20 Minuten',
    'ru': '20 минут',
  },
  30: {
    'tr': '30 dakika',
    'en': '30 minutes',
    'de': '30 Minuten',
    'ru': '30 минут',
  },
  45: {
    'tr': '45 dakika',
    'en': '45 minutes',
    'de': '45 Minuten',
    'ru': '45 минут',
  },
  60: {'tr': '1 saat', 'en': '1 hour', 'de': '1 Stunde', 'ru': '1 час'},
  90: {
    'tr': '1 saat 30 dakika',
    'en': '1 hour 30 minutes',
    'de': '1 Stunde 30 Minuten',
    'ru': '1 час 30 минут',
  },
  120: {'tr': '2 saat', 'en': '2 hours', 'de': '2 Stunden', 'ru': '2 часа'},
};

String notificationDurationLabel(int minutes, String lang) {
  final entry = notificationDurationLabels[minutes];
  if (entry == null) return '$minutes dk';
  return entry[lang] ?? entry['tr']!;
}
