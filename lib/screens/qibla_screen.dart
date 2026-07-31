import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../models/app_exception.dart';
import '../providers/app_settings.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner_widget.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final LocationService _locationService = LocationService();

  bool _loading = true;
  AppErrorCode? _errorCode;
  double? _qiblaBearing;
  double? _heading;
  bool _hasCompassSensor = true;
  StreamSubscription<CompassEvent>? _compassSub;

  // Ekrana girildiğinde pusula/sensör verisi henüz kararlı olmayabiliyor.
  // Yanlış yönlendirme yapmamak için ilk 30 saniye boyunca üstte bir
  // uyarı gösteriyoruz, süre dolunca kendiliğinden kayboluyor.
  bool _showAccuracyWarning = false;
  Timer? _accuracyWarningTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _accuracyWarningTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _errorCode = null;
      _showAccuracyWarning = true;
    });

    _accuracyWarningTimer?.cancel();
    _accuracyWarningTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) setState(() => _showAccuracyWarning = false);
    });

    try {
      final position = await _locationService.getCurrentLocation();
      final bearing =
          _calculateQiblaBearing(position.latitude, position.longitude);

      setState(() {
        _qiblaBearing = bearing;
        _loading = false;
      });

      if (FlutterCompass.events == null) {
        setState(() => _hasCompassSensor = false);
        return;
      }

      _compassSub?.cancel();
      _compassSub = FlutterCompass.events!.listen((event) {
        if (mounted && event.heading != null) {
          setState(() => _heading = event.heading);
        }
      });
    } catch (e) {
      setState(() {
        _errorCode = e is AppException ? e.code : AppErrorCode.unknown;
        _loading = false;
      });
    }
  }

  /// Kabe'nin sabit koordinatlarına göre, kullanıcının bulunduğu noktadan
  /// bakıldığında kıblenin gerçek kuzeye göre açısını (0-360°) hesaplar.
  double _calculateQiblaBearing(double lat, double lng) {
    const kaabaLat = 21.4225;
    const kaabaLng = 39.8262;

    final phiK = kaabaLat * pi / 180;
    final lambdaK = kaabaLng * pi / 180;
    final phi = lat * pi / 180;
    final lambda = lng * pi / 180;

    final psi = atan2(
      sin(lambdaK - lambda),
      cos(phi) * tan(phiK) - sin(phi) * cos(lambdaK - lambda),
    );

    return (psi * 180 / pi + 360) % 360;
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
      appBar: AppBar(title: Text(AppStrings.get('qiblaTitle', lang))),
      bottomNavigationBar: const AdBannerWidget(),
      body: Column(
        children: [
          if (_showAccuracyWarning) _buildAccuracyWarning(lang),
          Expanded(child: _buildBody(lang)),
        ],
      ),
    );
  }

  Widget _buildAccuracyWarning(String lang) {
    return Container(
      width: double.infinity,
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.get('qiblaAccuracyWarning', lang),
              style: TextStyle(
                color: Colors.amber.shade900,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
              onPressed: _init,
              child: Text(AppStrings.get('retry', lang)),
            ),
          ),
        ],
      );
    }

    if (!_hasCompassSensor) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            AppStrings.get('qiblaNoSensor', lang),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_heading == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                AppStrings.get('qiblaCalibrate', lang),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Kıble yönü ile telefonun baktığı yön arasındaki fark;
    // bu kadar döndürülen bir ok her zaman Kabe'yi gösterir.
    final angle = (_qiblaBearing! - _heading!) * pi / 180;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            AppStrings.get('qiblaInstruction', lang),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dış pusula çemberi
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: AppTheme.primaryGreen,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    // Telefonun baktığı sabit yönü gösteren işaret (üstte, dönmez)
                    Positioned(
                      top: 4,
                      child: Icon(
                        Icons.arrow_drop_up,
                        size: 34,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    // Kıble yönünü gösteren dönen ok
                    Transform.rotate(
                      angle: angle,
                      child: SizedBox(
                        width: 280,
                        height: 280,
                        child: Column(
                          children: [
                            const Icon(
                              Icons.mosque,
                              size: 40,
                              color: AppTheme.accentGold,
                            ),
                            Container(
                              width: 4,
                              height: 100,
                              color: AppTheme.accentGold,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Merkez nokta
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${AppStrings.get('qiblaBearingLabel', lang)}: ${_qiblaBearing!.toStringAsFixed(0)}°',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
