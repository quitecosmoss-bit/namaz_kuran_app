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
/// NOT: Bu bildirimler o günün namaz vakitleri için, uygulama Namaz
/// Vakitleri ekranı her açıldığında/yenilendiğinde planlanır. Telefonun
/// arka planda kendiliğinden her gün yeni vakitleri hesaplayabilmesi için
/// (uygulama hiç açılmadan) ayrı bir arka plan servisi gerekir; bu ilk
/// sürümde uygulamanın günde en az bir kez açılması yeterli - bir sonraki
/// açılışta o günün tüm hatırlatmaları otomatik olarak yeniden kurulur.
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
      final String timezoneName =
          (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timezoneName));
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
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

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
    if (dateTime.isBefore(DateTime.now())) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_reminders',
        'Namaz Vakti Hatırlatmaları',
        channelDescription:
            'Namaz vakitlerinden önce gönderilen hatırlatma bildirimleri',
        importance: Importance.max,
        priority: Priority.high,
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
        // pubspec.yaml'da flutter_local_notifications ^18.0.1 kullanıldığı
        // için (bu parametre 19.0.0'da kaldırıldı) hala zorunlu.
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // İzin verilmediyse ya da cihaz desteklemiyorsa sessizce atla;
      // uygulamanın geri kalanını etkilemesin.
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
}
