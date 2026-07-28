import 'package:flutter/material.dart';
import '../data/prayer_guide_data.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner_widget.dart';
import 'prayer_guide_detail_screen.dart';

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
