import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';
import 'surah_detail_screen.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Kuran-ı Kerim')),
      body: FutureBuilder<List<Surah>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${snapshot.error}'.replaceFirst('Exception: ', '')),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => _future = _service.getSurahList()),
                      child: const Text('Tekrar Dene'),
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
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  child: Text('${surah.number}'),
                ),
                title: Text(surah.englishNameTranslation),
                subtitle: Text(
                  '${surah.englishName} · ${surah.numberOfAyahs} ayet · ${surah.revelationType}',
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
