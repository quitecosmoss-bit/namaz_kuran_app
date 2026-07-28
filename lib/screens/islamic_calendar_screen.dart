import 'package:flutter/material.dart';
import '../models/app_exception.dart';
import '../services/hijri_calendar_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner_widget.dart';

const List<String> _gregorianMonthsTr = [
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
  final HijriCalendarService _service = HijriCalendarService();
  late int _year;
  late Future<List<IslamicEvent>> _future;

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year;
    _future = _service.getYearEvents(_year);
  }

  void _changeYear(int delta) {
    setState(() {
      _year += delta;
      _future = _service.getYearEvents(_year);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dini Günler Takvimi')),
      bottomNavigationBar: const AdBannerWidget(),
      body: Column(
        children: [
          Container(
            color: AppTheme.primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _changeYear(-1),
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                ),
                Text(
                  '$_year',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => _changeYear(1),
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Text(
              'Tarihler Diyanet İşleri Başkanlığı\'nın hesaplama yöntemiyle '
              'hesaplanmıştır; Regaib Kandili için "Recep ayının ilk Cuma '
              'gecesi" kuralı yaklaşık olarak uygulanmıştır. Kesin tarihler '
              'için Diyanet\'in resmi duyurularını kontrol ediniz.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<IslamicEvent>>(
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
                          const Text(
                            'Dini günler alınamadı. İnternet bağlantınızı '
                            'kontrol edip tekrar deneyin.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => setState(
                              () => _future = _service.getYearEvents(_year),
                            ),
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final events = snapshot.data ?? [];
                if (events.isEmpty) {
                  return const Center(
                    child: Text('Bu yıl için gösterilecek gün bulunamadı.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final e = events[index];
                    final showMonthHeader = index == 0 ||
                        events[index - 1].gregorianDate.month !=
                            e.gregorianDate.month;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showMonthHeader)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                            child: Text(
                              '${_gregorianMonthsTr[e.gregorianDate.month - 1]} $_year',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.accentGold,
                              foregroundColor: Colors.white,
                              child: Text('${e.gregorianDate.day}'),
                            ),
                            title: Text(
                              e.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text('Hicri: ${e.hijriLabel}'),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
