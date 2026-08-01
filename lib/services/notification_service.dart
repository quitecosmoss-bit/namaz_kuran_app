import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../localization/app_strings.dart';
import '../localization/notification_durations.dart';
import '../models/prayer_times.dart';

/// Namaz vakitlerinden önce iki hatırlatma bildirimi planlar. Süreler ve
/// dil, kullanıcının Ayarlar ekranındaki tercihlerine göre değişir.
///
/// Bildirimler flutter_local_notifications ile işletim sistemi seviyesinde
/// (exact alarm) planlanır; bu sayede uygulama tamamen kapalı/öldürülmüş
/// olsa bile zamanı geldiğinde tetiklenirler - uygulamanın o anda çalışıyor
/// olması gerekmez.
///
/// scheduleForUpcomingDays ile tek seferde birden çok günün (varsayılan 30
/// gün) hatırlatmaları önceden kurulur; böylece kullanıcı uygulamayı her
/// gün açmasa bile bildirimler aksamadan gelmeye devam eder. Uygulama en
/// az bu pencere içinde (örn. ayda bir) bir kez açıldığında planlama
/// otomatik olarak bir sonraki döneme uzatılır.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (_) {
      // Cihazın saat dilimi alınamazsa varsayılan (UTC) ile devam edilir;
      // bildirimler yine de çalışır ama saat kayması olabilir.
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final notifGranted = await androidImpl?.requestNotificationsPermission();
    final exactAlarmGranted =
        await androidImpl?.requestExactAlarmsPermission();

    if (kDebugMode) {
      // Bu ikisinden herhangi biri false ise bildirimler planlanamaz ya
      // da hiç görünmez - "hiç bildirim gelmiyor" şikayetinin en sık
      // sebebi budur.
      debugPrint(
        'Bildirim izinleri -> bildirim izni: $notifGranted, '
        'tam saat alarmı izni: $exactAlarmGranted',
      );
    }

    _initialized = true;
  }

  /// Sabit kimlikler: her vakit için 2 bildirim (saat öncesi / 15 dk öncesi).
  /// Aynı kimlikle tekrar planlama, öncekinin üzerine yazar - bu sayede
  /// ekran her yenilendiğinde bildirimler güncellenir, birikmez.
  static const Map<String, int> _baseIds = {
    'vaktFajr': 100,
    'vaktDhuhr': 200,
    'vaktAsr': 300,
    'vaktMaghrib': 400,
    'vaktIsha': 500,
  };

  DateTime _parseTimeToday(String hm) {
    final now = DateTime.now();
    final parts = hm.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// [_parseTimeToday]'den farklı olarak saati her zaman "bugün"e göre değil,
  /// ilgili [times] kaydının kendi tarihine göre çözer - çoklu gün planlaması
  /// (scheduleForUpcomingDays) için gerekli.
  DateTime _parseTimeForDate(PrayerTimes times, String hm) {
    final parts = hm.split(':');
    return DateTime(
      times.gregorianYear,
      times.gregorianMonth,
      times.gregorianDay,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  String _fillTemplate(String template, String label, String duration) {
    return template.replaceAll('{label}', label).replaceAll(
          '{duration}',
          duration,
        );
  }

  Future<void> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    final now = DateTime.now();
    if (dateTime.isBefore(now)) {
      // ÖNEMLİ: Bu bir hata değil ama sonucu aynı - bildirim hiç
      // kurulmuyor. Hesaplanan saat zaten geçmişse (ör. saat dilimi/tarih
      // hesaplamasında bir kayma varsa, ya da vakit bugün için çoktan
      // geçtiyse) buraya sessizce düşülüyordu. Artık en azından debug
      // modda görünür.
      if (kDebugMode) {
        debugPrint(
          'Bildirim ATLANDI (id=$id): hesaplanan zaman ($dateTime) '
          'şu andan ($now) önce - kurulmadı.',
        );
      }
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_reminders',
        'Namaz Vakti Hatırlatmaları',
        channelDescription:
            'Namaz vakitlerinden önce gönderilen hatırlatma bildirimleri',
        importance: Importance.max,
        priority: Priority.high,
        // Sessiz/başlıksız gelmesin diye ses ve titreşimi açıkça istiyoruz;
        // varsayılanlar zaten true ama kanal davranışını netleştirmek için
        // burada belirtiyoruz.
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 400, 200, 400]),
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(dateTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      if (kDebugMode) {
        debugPrint('Bildirim PLANLANDI (id=$id): $dateTime -> "$title"');
      }
    } catch (e, st) {
      // ÖNEMLİ: Burası daha önce tamamen sessizdi - "tam saat izni"
      // (exact alarm) verilmemişse plugin hata fırlatır ve bildirim hiç
      // planlanmaz, ama kullanıcı/geliştirici bunu asla göremezdi.
      // Şimdi en azından debug modda konsola yazdırıyoruz.
      if (kDebugMode) {
        debugPrint('Bildirim planlanamadı (id=$id, zaman=$dateTime): $e');
        debugPrint('$st');
      }
    }
  }

  /// Bugünün namaz vakitlerine göre tüm hatırlatmaları (yeniden) planlar.
  Future<void> scheduleForPrayerTimes(
    PrayerTimes times, {
    required int minutesBefore1,
    required int minutesBefore2,
    required String lang,
  }) async {
    if (!_initialized) await initialize();

    final vakitTimes = <String, String>{
      'vaktFajr': times.fajr,
      'vaktDhuhr': times.dhuhr,
      'vaktAsr': times.asr,
      'vaktMaghrib': times.maghrib,
      'vaktIsha': times.isha,
    };

    final title1 = AppStrings.get('notifTitle1', lang);
    final title2 = AppStrings.get('notifTitle2', lang);
    final bodyTemplate1 = AppStrings.get('notifBody1Template', lang);
    final bodyTemplate2 = AppStrings.get('notifBody2Template', lang);
    final duration1Label = notificationDurationLabel(minutesBefore1, lang);
    final duration2Label = notificationDurationLabel(minutesBefore2, lang);

    for (final entry in vakitTimes.entries) {
      final vaktKey = entry.key;
      final vaktDateTime = _parseTimeToday(entry.value);
      final label = AppStrings.get(vaktKey, lang);
      final baseId = _baseIds[vaktKey]!;

      await _scheduleOne(
        id: baseId + 1,
        title: title1,
        body: _fillTemplate(bodyTemplate1, label, duration1Label),
        dateTime: vaktDateTime.subtract(Duration(minutes: minutesBefore1)),
      );

      await _scheduleOne(
        id: baseId + 2,
        title: title2,
        body: _fillTemplate(bodyTemplate2, label, duration2Label),
        dateTime: vaktDateTime.subtract(Duration(minutes: minutesBefore2)),
      );
    }
  }

  /// [days] içindeki her gün için (bkz. PrayerService.getUpcomingPrayerTimes)
  /// 5 vakit x 2 bildirim planlar. Kimlikler gün sırasına göre (0, 1, 2, ...)
  /// türetilir - "bugünden itibaren N. gün" - mutlak takvim tarihine göre
  /// değil. Böylece her açılışta aynı offsetteki bildirimler üzerine
  /// yazılır ve zamanla birikip çakışma/gereksiz bildirim oluşmaz.
  Future<void> scheduleForUpcomingDays(
    List<PrayerTimes> days, {
    required int minutesBefore1,
    required int minutesBefore2,
    required String lang,
  }) async {
    if (!_initialized) await initialize();
    if (days.isEmpty) return;

    final title1 = AppStrings.get('notifTitle1', lang);
    final title2 = AppStrings.get('notifTitle2', lang);
    final bodyTemplate1 = AppStrings.get('notifBody1Template', lang);
    final bodyTemplate2 = AppStrings.get('notifBody2Template', lang);
    final duration1Label = notificationDurationLabel(minutesBefore1, lang);
    final duration2Label = notificationDurationLabel(minutesBefore2, lang);

    for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final times = days[dayIndex];
      final vakitTimes = <String, String>{
        'vaktFajr': times.fajr,
        'vaktDhuhr': times.dhuhr,
        'vaktAsr': times.asr,
        'vaktMaghrib': times.maghrib,
        'vaktIsha': times.isha,
      };

      // Her gün için ayrı bir kimlik bloğu (0, 1000, 2000, ...) ayırıyoruz;
      // baseId'ler (100-500) bu bloğun içine sığdığından çakışma olmaz.
      final dayBlockId = dayIndex * 1000;

      for (final entry in vakitTimes.entries) {
        final vaktKey = entry.key;
        final vaktDateTime = _parseTimeForDate(times, entry.value);
        final label = AppStrings.get(vaktKey, lang);
        final baseId = _baseIds[vaktKey]!;

        await _scheduleOne(
          id: dayBlockId + baseId + 1,
          title: title1,
          body: _fillTemplate(bodyTemplate1, label, duration1Label),
          dateTime: vaktDateTime.subtract(Duration(minutes: minutesBefore1)),
        );

        await _scheduleOne(
          id: dayBlockId + baseId + 2,
          title: title2,
          body: _fillTemplate(bodyTemplate2, label, duration2Label),
          dateTime: vaktDateTime.subtract(Duration(minutes: minutesBefore2)),
        );
      }
    }

    if (kDebugMode) {
      // Android'in (bizim kodumuzun değil, işletim sisteminin) o an
      // gerçekten elinde tuttuğu planlanmış bildirim sayısı. Bu sayı
      // yukarıdaki "PLANLANDI" loglarının toplamıyla eşleşmiyorsa,
      // sistem bir yerlerde iptal etmiş demektir (ör. force-stop sonrası).
      final pending = await _plugin.pendingNotificationRequests();
      debugPrint(
        'scheduleForUpcomingDays tamamlandı - OS\'te şu an bekleyen '
        'bildirim sayısı: ${pending.length}',
      );
    }
  }
}
