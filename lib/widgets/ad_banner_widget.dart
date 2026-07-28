import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google AdMob banner reklamı gösteren, tekrar kullanılabilir widget.
///
/// !!! ÖNEMLİ - YAYINLAMADAN ÖNCE MUTLAKA OKU !!!
/// Aşağıdaki reklam birimi kimliği (adUnitId) Google'ın herkese açık
/// TEST kimliğidir - gerçek para kazandırmaz, sadece test amaçlıdır.
/// Play Store'da YAYINLAMADAN ÖNCE:
///   1. admob.google.com üzerinden kendi hesabını oluştur
///   2. Uygulamanı ekleyip banner reklam birimleri oluştur
///   3. Aşağıdaki _testAdUnitId sabitini kendi gerçek ID'nle değiştir
///   4. AndroidManifest.xml'deki APPLICATION_ID meta-data değerini de
///      kendi gerçek AdMob Uygulama ID'nle değiştir (bkz. codemagic.yaml)
/// Test ID'siyle yayına çıkarsan reklamdan gelir elde edemezsin ve
/// Google, gerçek reklam yerine test reklamı göstermeye devam eder.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // TODO: Yayına almadan önce kendi AdMob reklam birimi ID'niz ile değiştirin.
  static const String _testAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _testAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      // Reklam henüz yüklenmediyse veya başarısız olduysa hiçbir şey
      // gösterme - görüntü kirliliği veya boş kutu bırakmamak için.
      return const SizedBox.shrink();
    }
    return SafeArea(
      child: Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
