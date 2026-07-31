import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Kullanıcı bir sureyi okuduktan sonra (geri çıkarken veya başka bir
/// sekmeye geçerken) gösterilen tam ekran (interstitial) reklamını
/// yöneten servis.
///
/// Gerçek AdMob interstitial reklam birimi ID'si kullanılıyor.
///
/// NOT: AdMob interstitial reklamların gösterim süresi bizim tarafımızdan
/// sabitlenemez — reklamın kapatma (X) butonu ne zaman aktif olacağını
/// (genelde birkaç saniye sonra) reklamı sağlayan tarafın kendi reklam
/// içeriği belirler, Google bunu bize açık bir "30 saniye" parametresi
/// olarak sunmuyor. Bu servis reklamı doğru anda (sureden çıkışta)
/// tetiklemekten sorumludur; gösterim süresi Google/reklamveren
/// tarafından kontrol edilir.
class InterstitialAdService {
  InterstitialAdService._();
  static final InterstitialAdService instance = InterstitialAdService._();

  // Gerçek AdMob interstitial reklam birimi ID'si.
  static const String _testAdUnitId =
      'ca-app-pub-4249557260220799/2725853764';

  InterstitialAd? _ad;
  bool _isLoading = false;

  /// Reklamı arka planda önceden yükler (kullanıcı sureyi okurken
  /// hazırlanır, böylece çıkış anında beklemeden gösterilebilir).
  void preload() {
    if (_ad != null || _isLoading) return;
    _isLoading = true;
    InterstitialAd.load(
      adUnitId: _testAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _isLoading = false;
        },
      ),
    );
  }

  /// Reklam hazırsa tam ekran gösterir; değilse (henüz yüklenmediyse ya
  /// da yüklenemediyse) kullanıcıyı bekletmeden doğrudan [onClosed]
  /// çağrılır. Böylece geri çıkış hiçbir zaman engellenmiş olmaz.
  void showIfReady({required VoidCallback onClosed}) {
    final ad = _ad;
    if (ad == null) {
      onClosed();
      // Bir sonraki sure çıkışı için tekrar yüklemeyi dene.
      preload();
      return;
    }

    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onClosed();
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        onClosed();
        preload();
      },
    );
    ad.show();
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
