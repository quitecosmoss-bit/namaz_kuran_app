import 'package:flutter/material.dart';

class WuduStep {
  final String title;
  final String description;
  final IconData icon;

  const WuduStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Hanefi mezhebine göre (Diyanet'in öğrettiği) abdest alma sırası.
const List<WuduStep> wuduSteps = [
  WuduStep(
    title: '1. Niyet ve Besmele',
    description:
        'Kalpten abdest almaya niyet edilir. "Bismillâhirrahmânirrahîm" '
        'denilerek abdeste başlanır.',
    icon: Icons.favorite_border,
  ),
  WuduStep(
    title: '2. Elleri Yıkama',
    description:
        'Eller bileklere kadar, parmak araları ovularak 3 kez yıkanır.',
    icon: Icons.back_hand,
  ),
  WuduStep(
    title: '3. Ağza Su Verme (Mazmaza)',
    description:
        'Sağ elle ağza su alınıp 3 kez çalkalanır, dişler ve ağız içi '
        'temizlenir.',
    icon: Icons.water_drop,
  ),
  WuduStep(
    title: '4. Buruna Su Çekme (İstinşak)',
    description:
        'Sağ elle buruna su çekilip, sol elle burun temizlenerek 3 kez '
        'tekrarlanır.',
    icon: Icons.air,
  ),
  WuduStep(
    title: '5. Yüzü Yıkama',
    description:
        'Alın saç bitiminden çene altına, bir kulaktan diğer kulağa kadar '
        'olan bölge 3 kez yıkanır.',
    icon: Icons.face_retouching_natural,
  ),
  WuduStep(
    title: '6. Sağ Kolu Yıkama',
    description: 'Sağ kol, dirsekle birlikte 3 kez yıkanır.',
    icon: Icons.pan_tool,
  ),
  WuduStep(
    title: '7. Sol Kolu Yıkama',
    description: 'Sol kol, dirsekle birlikte 3 kez yıkanır.',
    icon: Icons.pan_tool_outlined,
  ),
  WuduStep(
    title: '8. Başı Meshetme',
    description:
        'Eller ıslatılıp, parmaklar birleştirilerek baş bir kez öne doğru '
        'meshedilir (ıslak elle hafifçe sıvazlanır).',
    icon: Icons.face,
  ),
  WuduStep(
    title: '9. Kulakları ve Enseyi Meshetme',
    description:
        'İşaret parmaklarıyla kulak içleri, baş parmaklarla kulak '
        'arkaları meshedilir. Ardından elin arkasıyla ense meshedilir.',
    icon: Icons.hearing,
  ),
  WuduStep(
    title: '10. Sağ Ayağı Yıkama',
    description:
        'Sağ ayak, topukla birlikte ve parmak araları ovularak 3 kez '
        'yıkanır.',
    icon: Icons.directions_walk,
  ),
  WuduStep(
    title: '11. Sol Ayağı Yıkama',
    description:
        'Sol ayak, topukla birlikte ve parmak araları ovularak 3 kez '
        'yıkanır.',
    icon: Icons.directions_walk,
  ),
  WuduStep(
    title: '12. Abdest Sonrası Dua',
    description:
        'Kıbleye dönülüp şehadet getirilir: "Eşhedü en lâ ilâhe illallah '
        've eşhedü enne Muhammeden abdühû ve rasûlüh." Ardından '
        '"Allahümmec\'alnî minet-tevvâbîne vec\'alnî minel-mutetahhirîn" '
        'duası okunur. Abdest tamamlanmıştır.',
    icon: Icons.check_circle,
  ),
];
