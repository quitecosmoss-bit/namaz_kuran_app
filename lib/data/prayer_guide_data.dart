import '../models/prayer_guide.dart';

/// 5 vakit namazın rekat yapıları (Hanefi mezhebi, Diyanet'in öğrettiği
/// standart uygulama). Sünnet, farz ve vitir gruplarının rekat sayıları.
const List<PrayerDefinition> prayerGuides = [
  PrayerDefinition(
    name: 'Sabah Namazı',
    totalRekat: 4,
    groups: [
      RekatGroup(label: '2 Rekat Sünnet', rekatCount: 2, isFarz: false),
      RekatGroup(label: '2 Rekat Farz', rekatCount: 2, isFarz: true),
    ],
  ),
  PrayerDefinition(
    name: 'Öğle Namazı',
    totalRekat: 10,
    groups: [
      RekatGroup(label: '4 Rekat İlk Sünnet', rekatCount: 4, isFarz: false),
      RekatGroup(label: '4 Rekat Farz', rekatCount: 4, isFarz: true),
      RekatGroup(label: '2 Rekat Son Sünnet', rekatCount: 2, isFarz: false),
    ],
  ),
  PrayerDefinition(
    name: 'İkindi Namazı',
    totalRekat: 8,
    groups: [
      RekatGroup(label: '4 Rekat Sünnet', rekatCount: 4, isFarz: false),
      RekatGroup(label: '4 Rekat Farz', rekatCount: 4, isFarz: true),
    ],
  ),
  PrayerDefinition(
    name: 'Akşam Namazı',
    totalRekat: 5,
    groups: [
      RekatGroup(label: '3 Rekat Farz', rekatCount: 3, isFarz: true),
      RekatGroup(label: '2 Rekat Sünnet', rekatCount: 2, isFarz: false),
    ],
  ),
  PrayerDefinition(
    name: 'Yatsı Namazı',
    totalRekat: 13,
    groups: [
      RekatGroup(label: '4 Rekat İlk Sünnet', rekatCount: 4, isFarz: false),
      RekatGroup(label: '4 Rekat Farz', rekatCount: 4, isFarz: true),
      RekatGroup(label: '2 Rekat Son Sünnet', rekatCount: 2, isFarz: false),
      RekatGroup(
        label: '3 Rekat Vitir',
        rekatCount: 3,
        isFarz: false,
        isVitir: true,
      ),
    ],
  ),
];

/// Bir rekat grubu (örn. "4 Rekat Farz") için adım adım kılınış listesini
/// üretir. Farz namazların 3. ve 4. rekatlarında zam-ı sure okunmaz kuralı,
/// ara oturuş / son oturuş ayrımı ve vitirdeki kunut duası burada
/// otomatik olarak doğru yerlere yerleştirilir.
List<PrayerStep> generateSteps(RekatGroup group) {
  final steps = <PrayerStep>[];
  final n = group.rekatCount;

  for (int i = 1; i <= n; i++) {
    final bool zamSureOkunur = !group.isFarz || i <= 2;

    // --- Kıyam (ayakta durma, kıraat) ---
    if (i == 1) {
      steps.add(
        PrayerStep(
          title: '$i. Rekat - Kıyam (Başlangıç)',
          description:
              'Kıbleye dönülür, kalpten niyet edilir (örn. "Niyet ettim '
              'Allah rızası için ${group.label.toLowerCase()} namazı '
              'kılmaya"). Eller kulak hizasına kaldırılıp "Allahu Ekber" '
              'denilerek namaza başlanır (iftitah tekbiri), eller bağlanır.\n\n'
              'Sübhaneke duası okunur (bu dua yalnızca namazın ilk '
              'rekatında okunur).\n\n'
              'Ardından Eûzü-Besmele çekilip Fâtiha Sûresi okunur'
              '${zamSureOkunur ? ', peşinden bilinen kısa bir sûre veya birkaç âyet (zam-ı sûre) eklenir.' : '.'}',
          pose: PoseType.kiyam,
        ),
      );
    } else {
      steps.add(
        PrayerStep(
          title: '$i. Rekat - Kıyam',
          description:
              '"Allahu Ekber" denilerek ayağa kalkılır. Eûzü-Besmele çekilip '
              'Fâtiha Sûresi okunur'
              '${zamSureOkunur ? ', ardından kısa bir sûre veya birkaç âyet (zam-ı sûre) eklenir.' : '.'}',
          pose: PoseType.kiyam,
        ),
      );
    }

    if (group.isVitir && i == n) {
      steps.add(
        const PrayerStep(
          title: 'Kunut Duası',
          description:
              '"Allahu Ekber" denilerek eller tekrar kulak hizasına '
              'kaldırılır ve göbek altında bağlanır (kunut tekbiri). '
              'Kunut duaları ("Allahümme innâ nesteînüke..." ve '
              '"Allahümme iyyâke na\'büdü...") okunur.',
          pose: PoseType.kiyam,
        ),
      );
    }

    // --- Rükû ---
    steps.add(
      const PrayerStep(
        title: 'Rükû',
        description:
            '"Allahu Ekber" denilerek öne eğilinir, eller dizlere konur, '
            'sırt ve baş düz bir hizada tutulur. "Sübhâne Rabbiyel Azîm" '
            '(en az 3 kez) okunur.',
        pose: PoseType.ruku,
      ),
    );

    // --- Kavme ---
    steps.add(
      const PrayerStep(
        title: 'Kavme (Rükûdan Doğrulma)',
        description:
            '"Semi\'allâhü limen hamideh" denilerek tam doğrulunur, ayakta '
            'iken "Rabbenâ lekel hamd" denilir.',
        pose: PoseType.kiyam,
      ),
    );

    // --- 1. Secde ---
    steps.add(
      const PrayerStep(
        title: '1. Secde',
        description:
            '"Allahu Ekber" denilerek secdeye varılır (alın, burun, iki el, '
            'dizler ve ayak parmakları yere değer). "Sübhâne Rabbiyel A\'lâ" '
            '(en az 3 kez) okunur.',
        pose: PoseType.secde,
      ),
    );

    // --- Celse (iki secde arası oturuş) ---
    steps.add(
      const PrayerStep(
        title: 'Celse (Kısa Oturuş)',
        description: '"Allahu Ekber" denilerek kısaca doğrulup oturulur.',
        pose: PoseType.oturus,
      ),
    );

    // --- 2. Secde ---
    steps.add(
      const PrayerStep(
        title: '2. Secde',
        description:
            '"Allahu Ekber" denilerek tekrar secdeye varılır. '
            '"Sübhâne Rabbiyel A\'lâ" (en az 3 kez) okunur.',
        pose: PoseType.secde,
      ),
    );

    final bool isFinal = i == n;
    final bool isMiddleSit = !isFinal && i % 2 == 0;

    if (isFinal || isMiddleSit) {
      if (isFinal) {
        steps.add(
          const PrayerStep(
            title: 'Son Oturuş',
            description:
                '"Allahu Ekber" denilerek oturulur. "Ettehiyyâtü" duası '
                'okunur. Ardından "Allahümme salli..." ve "Allahümme '
                'bârik..." duaları, sonra dilerse "Rabbenâ" duaları okunur.',
            pose: PoseType.oturus,
          ),
        );
        steps.add(
          const PrayerStep(
            title: 'Selam',
            description:
                'Önce sağa dönülerek "Esselâmü aleyküm ve rahmetullah", '
                'sonra sola dönülerek aynı şekilde selam verilir. Namaz '
                'tamamlanır.',
            pose: PoseType.oturus,
          ),
        );
      } else {
        steps.add(
          const PrayerStep(
            title: 'Ara Oturuş',
            description:
                '"Allahu Ekber" denilerek oturulur. Yalnızca "Ettehiyyâtü" '
                'duası okunur (salli-bârik okunmaz), ardından "Allahu '
                'Ekber" denilerek ayağa kalkılıp namaza devam edilir.',
            pose: PoseType.oturus,
          ),
        );
      }
    } else {
      steps.add(
        PrayerStep(
          title: '${i + 1}. Rekata Geçiş',
          description: '"Allahu Ekber" denilerek doğrudan ayağa kalkılır.',
          pose: PoseType.kiyam,
        ),
      );
    }
  }

  return steps;
}
