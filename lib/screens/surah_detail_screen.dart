import 'package:flutter/material.dart';
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

  void _load(String languageCode) {
    _loadedForLanguage = languageCode;
    _future = _service.getSurahWithTranslation(
      surahNumber: widget.surah.number,
      languageCode: languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppSettings>().language;

    if (_loadedForLanguage != lang) {
      _load(lang);
    }

    return Scaffold(
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
    );
  }
}
