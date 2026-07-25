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

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final LocationService _locationService = LocationService();
  final PrayerService _prayerService = PrayerService();

  bool _loading = true;
  String? _error;
  PrayerTimes? _times;
  String? _cityInfo;

  @override
  void initState() {
    super.initState();
    _fetchTimes();
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
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
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
