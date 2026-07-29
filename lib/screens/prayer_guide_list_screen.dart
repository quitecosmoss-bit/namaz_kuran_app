import 'package:flutter/material.dart';
import '../data/prayer_guide_data.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner_widget.dart';
import 'prayer_guide_detail_screen.dart';
import 'wudu_guide_screen.dart';

class PrayerGuideListScreen extends StatelessWidget {
  const PrayerGuideListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Namaz Rehberi')),
      bottomNavigationBar: const AdBannerWidget(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Aşağıdaki 5 vakit namazdan birini seç, adım adım ve '
            'animasyonlu (isteğe bağlı sesli) şekilde nasıl kılındığını '
            'öğren.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: AppTheme.accentGold.withOpacity(0.12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppTheme.accentGold, width: 1.5),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.accentGold,
                child: Icon(Icons.water_drop, color: Colors.white),
              ),
              title: const Text(
                'ABDEST ALMA REHBERİ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: const Text('Adım adım doğru abdest alma şekli'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WuduGuideScreen()),
                );
              },
            ),
          ),
          const Divider(height: 8),
          const SizedBox(height: 8),
          ...prayerGuides.map(
            (guide) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryGreen,
                  child: const Icon(Icons.self_improvement,
                      color: Colors.white),
                ),
                title: Text(
                  guide.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text('${guide.totalRekat} rekat'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrayerGuideDetailScreen(guide: guide),
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
