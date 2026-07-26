/// Uygulama genelinde kullanılan tüm metinlerin 4 dildeki karşılıkları.
/// Kullanım: AppStrings.get('anahtarAdi', dilKodu)
class AppStrings {
  static const Map<String, Map<String, String>> _values = {
    'prayerTimesTitle': {
      'tr': 'Namaz Vakitleri',
      'en': 'Prayer Times',
      'de': 'Gebetszeiten',
      'ru': 'Времена молитв',
    },
    'quranTitle': {
      'tr': 'Kuran-ı Kerim',
      'en': 'The Holy Quran',
      'de': 'Der Heilige Koran',
      'ru': 'Священный Коран',
    },
    'settingsTitle': {
      'tr': 'Ayarlar',
      'en': 'Settings',
      'de': 'Einstellungen',
      'ru': 'Настройки',
    },
    'navQuran': {
      'tr': 'Kuran',
      'en': 'Quran',
      'de': 'Koran',
      'ru': 'Коран',
    },
    'currentlyPrefix': {
      'tr': 'Şu an',
      'en': 'Currently',
      'de': 'Derzeit',
      'ru': 'Сейчас',
    },
    'vaktiSuffix': {
      'tr': 'vakti',
      'en': '',
      'de': '',
      'ru': '',
    },
    'remainingUntilSuffix': {
      'tr': 'vaktine kalan süre',
      'en': 'time left until',
      'de': 'verbleibende Zeit bis',
      'ru': 'осталось времени до',
    },
    'location': {
      'tr': 'Konum',
      'en': 'Location',
      'de': 'Standort',
      'ru': 'Местоположение',
    },
    'calculationMethod': {
      'tr': 'Hesaplama: Diyanet İşleri Başkanlığı yöntemi',
      'en': 'Calculation: Diyanet (Turkey) method',
      'de': 'Berechnung: Diyanet-Methode (Türkei)',
      'ru': 'Расчёт: метод Диянет (Турция)',
    },
    'retry': {
      'tr': 'Tekrar Dene',
      'en': 'Retry',
      'de': 'Erneut versuchen',
      'ru': 'Повторить',
    },
    'ayah': {
      'tr': 'ayet',
      'en': 'verses',
      'de': 'Verse',
      'ru': 'аятов',
    },
    'meccan': {
      'tr': 'Mekke',
      'en': 'Meccan',
      'de': 'Mekkanisch',
      'ru': 'Мекканская',
    },
    'medinan': {
      'tr': 'Medine',
      'en': 'Medinan',
      'de': 'Medinensisch',
      'ru': 'Мединская',
    },
    'settingsSectionTitle': {
      'tr': 'Uygulama ve meal dili',
      'en': 'App & translation language',
      'de': 'App- und Übersetzungssprache',
      'ru': 'Язык приложения и перевода',
    },
    'settingsSectionDesc': {
      'tr':
          'Seçtiğin dil hem uygulama arayüzünü hem de Kuran mealini belirler.',
      'en':
          'The language you choose sets both the app interface and the Quran translation.',
      'de':
          'Die gewählte Sprache bestimmt sowohl die App-Oberfläche als auch die Koranübersetzung.',
      'ru':
          'Выбранный язык определяет как интерфейс приложения, так и перевод Корана.',
    },
    'vaktFajr': {'tr': 'İmsak', 'en': 'Fajr', 'de': 'Fajr', 'ru': 'Фаджр'},
    'vaktSunrise': {
      'tr': 'Güneş',
      'en': 'Sunrise',
      'de': 'Sonnenaufgang',
      'ru': 'Восход',
    },
    'vaktDhuhr': {'tr': 'Öğle', 'en': 'Dhuhr', 'de': 'Dhuhr', 'ru': 'Зухр'},
    'vaktAsr': {'tr': 'İkindi', 'en': 'Asr', 'de': 'Asr', 'ru': 'Аср'},
    'vaktMaghrib': {
      'tr': 'Akşam',
      'en': 'Maghrib',
      'de': 'Maghrib',
      'ru': 'Магриб',
    },
    'vaktIsha': {'tr': 'Yatsı', 'en': 'Isha', 'de': 'Isha', 'ru': 'Иша'},
    'qiblaTitle': {
      'tr': 'Kıble',
      'en': 'Qibla',
      'de': 'Qibla',
      'ru': 'Кибла',
    },
    'qiblaInstruction': {
      'tr':
          'Telefonunuzu düz tutun ve ok, üstteki sabit işaretle hizalanana kadar çevirin. Hizalandığında Kâbe yönüne dönmüş olursunuz.',
      'en':
          'Hold your phone flat and turn until the arrow lines up with the fixed marker at the top. Once aligned, you are facing the Kaaba.',
      'de':
          'Halte dein Telefon flach und drehe es, bis der Pfeil mit der festen Markierung oben übereinstimmt. Bei Ausrichtung schaust du zur Kaaba.',
      'ru':
          'Держите телефон горизонтально и поворачивайтесь, пока стрелка не совпадёт с меткой сверху. При совпадении вы обращены к Каабе.',
    },
    'qiblaBearingLabel': {
      'tr': 'Kıble açısı',
      'en': 'Qibla bearing',
      'de': 'Qibla-Richtung',
      'ru': 'Направление на Каабу',
    },
    'qiblaCalibrate': {
      'tr': 'Pusula verisi bekleniyor, telefonunuzu 8 çizerek hareket ettirin.',
      'en':
          'Waiting for compass data, move your phone in a figure-8 motion to calibrate.',
      'de':
          'Warte auf Kompassdaten, bewege dein Telefon in einer Achterbewegung zur Kalibrierung.',
      'ru':
          'Ожидание данных компаса, подвигайте телефон восьмёркой для калибровки.',
    },
    'qiblaNoSensor': {
      'tr':
          'Cihazınızda pusula (manyetometre) sensörü bulunamadı, bu özellik kullanılamıyor.',
      'en':
          'No compass (magnetometer) sensor found on this device, this feature is unavailable.',
      'de':
          'Auf diesem Gerät wurde kein Kompass- (Magnetometer-) Sensor gefunden, diese Funktion ist nicht verfügbar.',
      'ru':
          'На этом устройстве не найден датчик компаса (магнитометр), эта функция недоступна.',
    },
    'errorLocationServiceDisabled': {
      'tr': 'Konum servisleri kapalı. Lütfen telefonunuzun konum ayarını açın.',
      'en':
          'Location services are off. Please turn on location in your phone settings.',
      'de':
          'Standortdienste sind deaktiviert. Bitte aktiviere den Standort in den Telefoneinstellungen.',
      'ru':
          'Службы геолокации отключены. Включите местоположение в настройках телефона.',
    },
    'errorLocationPermissionDenied': {
      'tr': 'Konum izni verilmedi.',
      'en': 'Location permission was not granted.',
      'de': 'Standortberechtigung wurde nicht erteilt.',
      'ru': 'Разрешение на геолокацию не предоставлено.',
    },
    'errorLocationPermissionDeniedForever': {
      'tr':
          'Konum izni kalıcı olarak reddedilmiş. Telefon ayarlarından uygulamaya konum izni vermeniz gerekiyor.',
      'en':
          'Location permission was permanently denied. Please enable it from your phone settings.',
      'de':
          'Standortberechtigung wurde dauerhaft verweigert. Bitte aktiviere sie in den Telefoneinstellungen.',
      'ru':
          'Разрешение на геолокацию отклонено навсегда. Включите его в настройках телефона.',
    },
    'errorNetwork': {
      'tr': 'Veriler alınamadı. İnternet bağlantınızı kontrol edip tekrar deneyin.',
      'en': 'Could not fetch data. Check your internet connection and try again.',
      'de':
          'Daten konnten nicht geladen werden. Bitte Internetverbindung prüfen und erneut versuchen.',
      'ru':
          'Не удалось получить данные. Проверьте подключение к интернету и повторите попытку.',
    },
  };

  static String get(String key, String lang) {
    final entry = _values[key];
    if (entry == null) return key;
    return entry[lang] ?? entry['tr'] ?? key;
  }
}
