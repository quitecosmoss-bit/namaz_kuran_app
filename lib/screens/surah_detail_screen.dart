import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../models/ayah.dart';
import '../models/surah.dart';
import '../providers/app_settings.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';
import 'quran_list_screen.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final QuranService _service = QuranService();
  Future<List<AyahPair>>? _future;
  String? _loadedForLanguage;

  // !!! ÖNEMLİ - YAYINLAMADAN ÖNCE MUTLAKA OKU !!!
  // Bu, Google'ın herkese açık TEST geçiş (interstitial) reklam birimi
  // kimliğidir - gerçek para kazandırmaz, sadece test amaçlıdır.
  // Play Store'da yayınlamadan önce ad_banner_widget.dart'taki notta
  // anlatıldığı gibi kendi gerçek AdMob geçiş reklamı ID'niz ile değiştirin.
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  InterstitialAd? _interstitialAd;
  bool _isExiting = false;

  void _load(String languageCode) {
    _loadedForLanguage = languageCode;
    _future = _service.getSurahWithTranslation(
      surahNumber: widget.surah.number,
      languageCode: languageCode,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _testInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  /// Sure ekranından geri çıkılırken (geri tuşu veya başka bir sekmeye
  /// dönüş için ekranın kapatılması) çağrılır. Reklam yüklenmişse önce
  /// tam ekran geçiş reklamını gösterir, kapatıldığında ekrandan çıkar.
  /// Reklam henüz yüklenmediyse kullanıcıyı bekletmeden direkt çıkar.
  Future<void> _handleExit() async {
    if (_isExiting) return;
    _isExiting = true;

    final ad = _interstitialAd;
    if (ad == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (mounted) Navigator.of(context).pop();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (mounted) Navigator.of(context).pop();
      },
    );
    ad.show();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppSettings>().language;

    if (_loadedForLanguage != lang) {
      _load(lang);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleExit();
      },
        child: Scaffold(
        appBar: AppBar(
          title: Text(surahDisplayName(widget.surah, lang)),
        ),
        body: FutureBuilder<List<AyahPair>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    AppStrings.get('errorNetwork', lang),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final ayahs = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ayahs.length,
              itemBuilder: (context, index) {
                final ayah = ayahs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppTheme.accentGold,
                              child: Text(
                                '${ayah.numberInSurah}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          ayah.arabicText,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 22, height: 1.8),
                        ),
                        if (ayah.transliterationText.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            ayah.transliterationText,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const Divider(height: 24),
                        Text(
                          ayah.translationText,
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        ),
    );
  }
}
