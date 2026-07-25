import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ayah.dart';
import '../models/surah.dart';
import '../providers/app_settings.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';

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

  void _load(String languageCode) {
    _loadedForLanguage = languageCode;
    _future = _service.getSurahWithTranslation(
      surahNumber: widget.surah.number,
      languageCode: languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettings>();

    // Dil değiştiyse yeniden yükle
    if (_loadedForLanguage != appSettings.mealLanguage) {
      _load(appSettings.mealLanguage);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.englishNameTranslation),
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
                  '${snapshot.error}'.replaceFirst('Exception: ', ''),
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
                        style: const TextStyle(
                          fontSize: 22,
                          height: 1.8,
                        ),
                      ),
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
    );
  }
}
