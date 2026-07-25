import 'dart:async';
import 'package:flutter/material.dart';
import '../models/prayer_times.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../theme/app_theme.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerStatus {
  final String currentLabel;
  final String nextLabel;
  final Duration remaining;

  _PrayerStatus({
    required this.currentLabel,
    required this.nextLabel,
    required this.remaining,
  });
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final LocationService _locationService = LocationService();
  final PrayerService _prayerService = PrayerService();

  bool _loading = true;
  String? _error;
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
      _error = null;
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

      // Vakit sayacını her saniye güncellemek için bir zamanlayıcı başlat
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  /// Verilen "HH:mm" metnini bugünün tarihiyle birleştirip DateTime'a çevirir.
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

  /// Şu an hangi vakitte olduğumuzu ve bir sonraki vakte kalan süreyi hesaplar.
  _PrayerStatus _computeStatus(PrayerTimes times) {
    final now = DateTime.now();

    final points = <MapEntry<String, DateTime>>[
      MapEntry('İmsak', _parseTimeToday(times.fajr)),
      MapEntry('Güneş', _parseTimeToday(times.sunrise)),
      MapEntry('Öğle', _parseTimeToday(times.dhuhr)),
      MapEntry('İkindi', _parseTimeToday(times.asr)),
      MapEntry('Akşam', _parseTimeToday(times.maghrib)),
      MapEntry('Yatsı', _parseTimeToday(times.isha)),
    ];

    for (int i = 0; i < points.length; i++) {
      if (now.isBefore(points[i].value)) {
        final currentLabel = i == 0 ? 'Yatsı' : points[i - 1].key;
        return _PrayerStatus(
          currentLabel: currentLabel,
          nextLabel: points[i].key,
          remaining: points[i].value.difference(now),
        );
      }
    }

    // Yatsı vaktini geçtiysek: şu an Yatsı vaktindeyiz,
    // bir sonraki vakit yarınki İmsak (yaklaşık olarak bugünün saatiyle).
    final tomorrowFajr = points.first.value.add(const Duration(days: 1));
    return _PrayerStatus(
      currentLabel: 'Yatsı',
      nextLabel: 'İmsak',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Namaz Vakitleri')),
      body: RefreshIndicator(
        onRefresh: _fetchTimes,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Icon(Icons.location_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _fetchTimes,
              child: const Text('Tekrar Dene'),
            ),
          ),
        ],
      );
    }

    final times = _times!;
    final status = _computeStatus(times);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
                  'Şu an: ${status.currentLabel} vakti',
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
                  '${status.nextLabel} vaktine kalan süre',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...times.toDisplayList().map(
              (entry) => Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time,
                      color: AppTheme.primaryGreen),
                  title: Text(entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
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
            'Konum: $_cityInfo\nHesaplama: Diyanet İşleri Başkanlığı yöntemi',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
