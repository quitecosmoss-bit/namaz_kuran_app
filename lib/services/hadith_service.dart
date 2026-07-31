import '../data/hadith_data.dart';
import '../models/hadith.dart';

/// Listedeki 50 hadisten, günün tarihine ve saatine göre "günün hadisi"ni
/// belirleyen basit servis. Ekstra bir depolama (shared_preferences vb.)
/// gerekmez: hesap tamamen deterministiktir, bu sayede hadis günde tam
/// olarak 2 kez (gece yarısı ve öğle vakti sınırlarında) otomatik olarak
/// değişir ve uygulama her açıldığında aynı yarım günde hep aynı hadis
/// gösterilir.
class HadithService {
  HadithService._();

  /// [now] verilmezse gerçek sistem saati kullanılır (teste kolaylık
  /// olsun diye parametre olarak dışarıdan da verilebilir).
  static Hadith getCurrentHadith([DateTime? now]) {
    final n = now ?? DateTime.now();
    final startOfYear = DateTime(n.year, 1, 1);
    final dayOfYear = n.difference(startOfYear).inDays;

    // Gün, 00:00-11:59 ve 12:00-23:59 olmak üzere iki periyoda ayrılır;
    // bu sayede hadis günde tam 2 kez değişir.
    final periodIndex = n.hour < 12 ? 0 : 1;

    final index = (dayOfYear * 2 + periodIndex) % hadithList.length;
    return hadithList[index];
  }
}
