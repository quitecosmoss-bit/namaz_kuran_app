enum PoseType { kiyam, ruku, secde, oturus }

class PrayerStep {
  final String title;
  final String description;
  final PoseType pose;

  const PrayerStep({
    required this.title,
    required this.description,
    required this.pose,
  });
}

class RekatGroup {
  final String label;
  final int rekatCount;
  final bool isFarz;
  final bool isVitir;

  const RekatGroup({
    required this.label,
    required this.rekatCount,
    required this.isFarz,
    this.isVitir = false,
  });
}

class PrayerDefinition {
  final String name;
  final int totalRekat;
  final List<RekatGroup> groups;

  const PrayerDefinition({
    required this.name,
    required this.totalRekat,
    required this.groups,
  });
}
