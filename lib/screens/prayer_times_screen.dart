import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../localization/date_translations.dart';
import '../models/app_exception.dart';
import '../models/prayer_times.dart';
import '../providers/app_settings.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner_widget.dart';
import 'islamic_calendar_screen.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerStatus {
  final String currentKey;
  final String nextKey;
  final Duration remaining;

  _PrayerStatus({
    required this.currentKey,
    required this.nextKey,
    required this.remaining,
  });
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with WidgetsBindingObserver {
  final LocationService _locationService = LocationService();
  final PrayerService _prayerService = PrayerService();

  bool _loading = true;
  AppErrorCode? _errorCode;
  PrayerTimes? _times;
  String? _cityInfo;
  String? _placeLabel;
  Timer? _ticker;

  // _times hangi takvim gününe ait şu an ekranda tutuluyor; ticker ve
  // yaşam döngüsü kontrolleri bunu gerçek "bugün" ile karşılaştırıp
  // tarih değiştiğinde otomatik yeniden çekim tetikler.
  DateTime? _timesDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchTimes();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama arka plandan (ör. bir gün sonra) ön plana dönerse, elimizdeki
    // vakitler hâlâ o eski günden kalma olabilir - kontrol edip gerekirse
    // taze veriyi çekiyoruz.
    if (state == AppLifecycleState.resumed) {
      _refetchIfDateChanged();
    }
  }

  /// Ekranda tutulan vakitler artık "bugüne" ait değilse (gece yarısı geçmiş,
  /// uygulama kapatılmadan açık kalmış olabilir) sessizce yeniden çeker.
  void _refetchIfDateChanged() {
    if (_loading) return;
    final today = DateTime.now();
    final isSameDay = _timesDate != null &&
        _timesDate!.year == today.year &&
        _timesDate!.month == today.month &&
        _timesDate!.day == today.day;
    if (!isSameDay) {
      _fetchTimes();
    }
  }

  Future<void> _fetchTimes() async {
    setState(() {
      _loading = true;
      _errorCode = null;
      _placeLabel = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      final times = await _prayerService.getTodayPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _times = times;
        _timesDate = DateTime(
          times.gregorianYear,
          times.gregorianMonth,
          times.gregorianDay,
        );
        _cityInfo =
            '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
        _loading = false;
      });

      if (mounted) {
        final appSettings = context.read<AppSettings>();
        // ÖNEMLİ: Eskiden sadece o günün 5 vakti planlanıyordu, bu yüzden
        // kullanıcı uygulamayı her gün açmadıkça bildirimler kesiliyordu.
        // Şimdi önümüzdeki ~30 günü tek seferde çekip planlıyoruz; ekran
        // her açıldığında bu pencere yeniden ileri kaydırılıyor. UI'ı
        // bloklamaması için sonucunu beklemiyoruz (fire-and-forget), hata
        // olursa (ağ yoksa vb.) sessizce yutuyoruz - zaten bir sonraki
        // açılışta tekrar denenecek.
        _prayerService
            .getUpcomingPrayerTimes(
          latitude: position.latitude,
          longitude: position.longitude,
        )
            .then((days) {
          if (!mounted) return;
          NotificationService.instance.scheduleForUpcomingDays(
            days,
            minutesBefore1: appSettings.notifyMinutes1,
            minutesBefore2: appSettings.notifyMinutes2,
            lang: appSettings.language,
          );
        }).catchError((_) {
          // Aylık planlama başarısız olsa da bugünün vakitleri zaten
          // yukarıda gösterildi; kullanıcı deneyimini bozmuyoruz.
        });
      }

      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        // Uygulama hiç arka plana atılmadan (didChangeAppLifecycleState
        // tetiklenmeden) açık kalıp gece yarısını geçmesi ihtimaline karşı
        // burada da tarih kontrolü yapıyoruz.
        _refetchIfDateChanged();
        setState(() {});
      });

      // İlçe/İl adını arka planda getir; başarısız olursa sessizce yok say,
      // ana ekranı (namaz vakitlerini) etkilemesin.
      _locationService
          .getPlaceLabel(
        latitude: position.latitude,
        longitude: position.longitude,
      )
          .then((label) {
        if (mounted) setState(() => _placeLabel = label);
      });
    } catch (e) {
      setState(() {
        _errorCode = e is AppException ? e.code : AppErrorCode.unknown;
        _loading = false;
      });
    }
  }

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

  _PrayerStatus _computeStatus(PrayerTimes times) {
    final now = DateTime.now();

    final points = <MapEntry<String, DateTime>>[
      MapEntry('vaktFajr', _parseTimeToday(times.fajr)),
      MapEntry('vaktSunrise', _parseTimeToday(times.sunrise)),
      MapEntry('vaktDhuhr', _parseTimeToday(times.dhuhr)),
      MapEntry('vaktAsr', _parseTimeToday(times.asr)),
      MapEntry('vaktMaghrib', _parseTimeToday(times.maghrib)),
      MapEntry('vaktIsha', _parseTimeToday(times.isha)),
    ];

    for (int i = 0; i < points.length; i++) {
      if (now.isBefore(points[i].value)) {
        final currentKey = i == 0 ? 'vaktIsha' : points[i - 1].key;
        return _PrayerStatus(
          currentKey: currentKey,
          nextKey: points[i].key,
          remaining: points[i].value.difference(now),
        );
      }
    }

    final tomorrowFajr = points.first.value.add(const Duration(days: 1));
    return _PrayerStatus(
      currentKey: 'vaktIsha',
      nextKey: 'vaktFajr',
      remaining: tomorrowFajr.difference(now),
    );
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _errorKey(AppErrorCode code) {
    switch (code) {
      case AppErrorCode.locationServiceDisabled:
        return 'errorLocationServiceDisabled';
      case AppErrorCode.locationPermissionDenied:
        return 'errorLocationPermissionDenied';
      case AppErrorCode.locationPermissionDeniedForever:
        return 'errorLocationPermissionDeniedForever';
      default:
        return 'errorNetwork';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppSettings>().language;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.calendar_month),
          tooltip: 'Dini Günler Takvimi',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const IslamicCalendarScreen(),
              ),
            );
          },
        ),
        title: Text(AppStrings.get('prayerTimesTitle', lang)),
      ),
      bottomNavigationBar: const AdBannerWidget(),
      body: RefreshIndicator(
        onRefresh: _fetchTimes,
        child: _buildBody(lang),
      ),
    );
  }

  Widget _buildBody(String lang) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorCode != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Icon(Icons.location_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              AppStrings.get(_errorKey(_errorCode!), lang),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _fetchTimes,
              child: Text(AppStrings.get('retry', lang)),
            ),
          ),
        ],
      );
    }

    final times = _times!;
    final status = _computeStatus(times);

    final vaktList = <MapEntry<String, String>>[
      MapEntry('vaktFajr', times.fajr),
      MapEntry('vaktSunrise', times.sunrise),
      MapEntry('vaktDhuhr', times.dhuhr),
      MapEntry('vaktAsr', times.asr),
      MapEntry('vaktMaghrib', times.maghrib),
      MapEntry('vaktIsha', times.isha),
    ];

    final currentLabel = AppStrings.get(status.currentKey, lang);
    final nextLabel = AppStrings.get(status.nextKey, lang);
    final vaktiSuffix = AppStrings.get('vaktiSuffix', lang);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: AppTheme.primaryGreen,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      formatGregorianDate(times, lang),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      times.hijriDate,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${AppStrings.get('currentlyPrefix', lang)}: $currentLabel${vaktiSuffix.isNotEmpty ? ' $vaktiSuffix' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDuration(status.remaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$nextLabel ${AppStrings.get('remainingUntilSuffix', lang)}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (_placeLabel != null)
                Positioned(
                  top: 10,
                  right: 14,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.white70),
                      const SizedBox(width: 3),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 130),
                        child: Text(
                          _placeLabel!,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...vaktList.map(
          (entry) {
            final isCurrent = entry.key == status.currentKey;
            return Card(
              color: isCurrent
                  ? AppTheme.accentGold.withOpacity(0.12)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isCurrent
                    ? const BorderSide(
                        color: AppTheme.accentGold, width: 2)
                    : BorderSide.none,
              ),
              child: ListTile(
                leading: Icon(
                  isCurrent ? Icons.access_time_filled : Icons.access_time,
                  color: AppTheme.primaryGreen,
                ),
                title: Row(
                  children: [
                    Text(
                      AppStrings.get(entry.key, lang),
                      style: TextStyle(
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ŞU AN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: isCurrent ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '${AppStrings.get('location', lang)}: $_cityInfo\n${AppStrings.get('calculationMethod', lang)}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
