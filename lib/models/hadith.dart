/// Tek bir hadis-i şerifi (metin + kaynak) temsil eden basit model.
class Hadith {
  final String text;

  /// Klasik hadis usulünde kullanılan kısaltılmış kaynak gösterimi,
  /// örn. "Buhârî, İman, 1" ya da "Müslim, Birr, 66".
  final String source;

  const Hadith({required this.text, required this.source});
}
