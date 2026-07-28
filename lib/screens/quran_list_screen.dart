import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../localization/surah_names_tr.dart';
import '../models/app_exception.dart';
import '../models/surah.dart';
import '../providers/app_settings.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner_widget.dart';
import 'surah_detail_screen.dart';

/// Sure adını, geçerli uygulama diline göre döner.
/// - tr: Diyanet'in kullandığı Türkçe isim
/// - en: API'den gelen İngilizce meal ismi
/// - de/ru: Güvenilir bir çeviri kaynağı olmadığından, yanlış isim
///   vermemek için Latin harfli okunuşu (örn. "Al-Baqara") gösterilir.
String surahDisplayName(Surah surah, String lang) {
  switch (lang) {
    case 'tr':
      return turkishSurahNames[surah.number - 1];
    case 'en':
      return surah.englishNameTranslation;
    default:
      return surah.englishName;
  }
}

class QuranListScreen extends StatefulWidget {
  const QuranListScreen({super.key});

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> {
  final QuranService _service = QuranService();
  late Future<List<Surah>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getSurahList();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppSettings>().language;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('quranTitle', lang))),
      bottomNavigationBar: const AdBannerWidget(),
      body: FutureBuilder<List<Surah>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final code = snapshot.error is AppException
                ? (snapshot.error as AppException).code
                : AppErrorCode.unknown;
            final key =
                code == AppErrorCode.network || code == AppErrorCode.unknown
                    ? 'errorNetwork'
                    : 'errorNetwork';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.get(key, lang),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => _future = _service.getSurahList()),
                      child: Text(AppStrings.get('retry', lang)),
                    ),
                  ],
                ),
              ),
            );
          }

          final surahs = snapshot.data ?? [];
          return ListView.separated(
            itemCount: surahs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final surah = surahs[index];
              final revelationLabel = surah.revelationType == 'Meccan'
                  ? AppStrings.get('meccan', lang)
                  : AppStrings.get('medinan', lang);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  child: Text('${surah.number}'),
                ),
                title: Text(surahDisplayName(surah, lang)),
                subtitle: Text(
                  '${surah.englishName} · ${surah.numberOfAyahs} ${AppStrings.get('ayah', lang)} · $revelationLabel',
                ),
                trailing: Text(
                  surah.name,
                  style: const TextStyle(fontSize: 18),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahDetailScreen(surah: surah),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
