import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google AdMob banner reklamı gösteren, tekrar kullanılabilir widget.
///
/// Gerçek AdMob reklam birimi ID'si kullanılıyor (App ID:
/// ca-app-pub-4249557260220799~6964481678 - bkz. codemagic.yaml).
/// Play Store'a yüklemeden önce AdMob panelinde bu reklam biriminin
/// "aktif" durumda olduğunu ve uygulamanın AdMob'da onaylandığını
/// kontrol et.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // Gerçek AdMob banner reklam birimi ID'si.
  static const String _testAdUnitId =
      'ca-app-pub-4249557260220799/8400138263';

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
          // Sebep "gerçek gelir yok/gösterecek reklam bulunamadı" (no fill,
          // code 3) gibi geçici bir durum mu, yoksa gerçek bir yapılandırma
          // hatası mı (kod 0/1/2) - bunu ayırt edebilmek için hatayı debug
          // modda konsola yazdırıyoruz. Kullanıcı arayüzünü etkilemez.
          if (kDebugMode) {
            debugPrint(
              'AdMob banner yüklenemedi: kod=${error.code} '
              'alan=${error.domain} mesaj=${error.message}',
            );
          }
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
