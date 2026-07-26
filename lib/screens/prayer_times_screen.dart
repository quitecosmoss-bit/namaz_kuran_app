import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../models/app_exception.dart';
import '../models/prayer_times.dart';
import '../providers/app_settings.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../theme/app_theme.dart';
import 'prayer_guide_list_screen.dart';

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

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final LocationService _locationService = LocationService();
  final PrayerService _prayerService = PrayerService();

  bool _loading = true;
  AppErrorCode? _errorCode;
  PrayerTimes? _times;
  String? _cityInfo;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _fetchTimes();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _fetchTimes() async {
    setState(() {
      _loading = true;
      _errorCode = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      final times = await _prayerService.getTodayPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _times = times;
        _cityInfo =
            '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
        _loading = false;
      });

      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
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
      appBar: AppBar(title: Text(AppStrings.get('prayerTimesTitle', lang))),
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
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 190,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrayerGuideListScreen(),
                  ),
                );
              },
              child: const Column(
                children: [
                  Icon(Icons.self_improvement, size: 22),
                  SizedBox(height: 6),
                  Text(
                    'HADİ NAMAZ KILMAYI\nBERABER ÖĞRENELİM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: AppTheme.primaryGreen,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  times.readableDate,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  times.hijriDate,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
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
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...vaktList.map(
          (entry) => Card(
            child: ListTile(
              leading:
                  const Icon(Icons.access_time, color: AppTheme.primaryGreen),
              title: Text(
                AppStrings.get(entry.key, lang),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Text(
                entry.value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ),
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
