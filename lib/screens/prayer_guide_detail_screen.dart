import 'package:flutter/material.dart';
import '../models/prayer_guide.dart';
import '../theme/app_theme.dart';
import 'rekat_walkthrough_screen.dart';

class PrayerGuideDetailScreen extends StatelessWidget {
  final PrayerDefinition guide;

  const PrayerGuideDetailScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(guide.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppTheme.primaryGreen,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    guide.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Toplam ${guide.totalRekat} rekat',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bölüm seç, adım adım kılınışını gör:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...guide.groups.map(
            (group) => Card(
              margin: const EdgeInsets.only(top: 8),
              child: ListTile(
                leading: Icon(
                  group.isVitir
                      ? Icons.nightlight_round
                      : (group.isFarz ? Icons.star : Icons.star_border),
                  color: AppTheme.accentGold,
                ),
                title: Text(group.label),
                subtitle: Text(
                  group.isVitir
                      ? 'Vacip'
                      : (group.isFarz ? 'Farz' : 'Sünnet'),
                ),
                trailing: const Icon(Icons.play_circle_fill,
                    color: AppTheme.primaryGreen),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RekatWalkthroughScreen(
                        prayerName: guide.name,
                        group: group,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
