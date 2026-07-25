import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';
import '../models/ayah.dart';

class QuranService {
  static const _baseUrl = 'https://api.alquran.cloud/v1';

  /// Desteklenen meal dilleri ve karşılık gelen edition kimlikleri.
  /// Not: alquran.cloud'un /edition?language=xx uç noktasından
  /// güncel edition listesini kontrol edip istersen değiştirebilirsin.
  static const Map<String, String> translationEditions = {
    'tr': 'tr.diyanet', // Diyanet İşleri Başkanlığı meali
    'en': 'en.sahih', // Saheeh International
    'de': 'de.bubenheim', // Bubenheim & Elyas
    'ru': 'ru.kuliev', // Elmir Kuliev
  };

  static const Map<String, String> languageLabels = {
    'tr': 'Türkçe',
    'en': 'English',
    'de': 'Deutsch',
    'ru': 'Русский',
  };

  static const String arabicEdition = 'quran-uthmani';

  Future<List<Surah>> getSurahList() async {
    final uri = Uri.parse('$_baseUrl/surah');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Sure listesi alınamadı (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final List list = data['data'];
    return list.map((e) => Surah.fromJson(e)).toList();
  }

  Future<List<AyahPair>> getSurahWithTranslation({
    required int surahNumber,
    required String languageCode,
  }) async {
    final translationEdition =
        translationEditions[languageCode] ?? translationEditions['tr']!;

    // Arapça orijinal metin ile seçilen dildeki meali paralel çekiyoruz.
    final results = await Future.wait([
      http.get(Uri.parse('$_baseUrl/surah/$surahNumber/$arabicEdition')),
      http.get(Uri.parse('$_baseUrl/surah/$surahNumber/$translationEdition')),
    ]);

    for (final r in results) {
      if (r.statusCode != 200) {
        throw Exception('Sure içeriği alınamadı (${r.statusCode})');
      }
    }

    final arabicJson =
        jsonDecode(results[0].body)['data']['ayahs'] as List;
    final translationJson =
        jsonDecode(results[1].body)['data']['ayahs'] as List;

    final List<AyahPair> pairs = [];
    for (int i = 0; i < arabicJson.length; i++) {
      pairs.add(
        AyahPair(
          numberInSurah: arabicJson[i]['numberInSurah'],
          arabicText: arabicJson[i]['text'],
          translationText:
              i < translationJson.length ? translationJson[i]['text'] : '',
        ),
      );
    }
    return pairs;
  }
}
