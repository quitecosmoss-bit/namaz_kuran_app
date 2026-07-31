import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../services/hadith_service.dart';
import '../theme/app_theme.dart';

/// Ana ekranın en üstünde sabit duran, "GÜNÜN HADİS-İ ŞERİFİ" başlığının
/// altında günün hadisini sağdan sola kayan bir şerit (marquee) halinde
/// gösteren banner. Hadis günde 2 kez otomatik olarak değişir
/// (bkz. HadithService).
class HadithBannerWidget extends StatelessWidget {
  const HadithBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final hadith = HadithService.getCurrentHadith();
    final fullText = '${hadith.text}   •   ${hadith.source}';

    return Container(
      width: double.infinity,
      color: AppTheme.primaryGreen,
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'GÜNÜN HADİS-İ ŞERİFİ',
            style: TextStyle(
              color: AppTheme.accentGold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 20,
            child: _MarqueeText(text: fullText),
          ),
        ],
      ),
    );
  }
}

/// Verilen metni, container genişliği kadar sağdan başlayıp sürekli
/// sola doğru kayan (klasik "kayan yazı") bir şerit halinde gösterir.
class _MarqueeText extends StatefulWidget {
  final String text;

  const _MarqueeText({required this.text});

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final Ticker _ticker;

  // Kayma hızı: saniyede kaç piksel ilerleyeceği.
  static const double _pixelsPerSecond = 40;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;

    final offset =
        (elapsed.inMilliseconds / 1000.0 * _pixelsPerSecond) % maxExtent;
    _scrollController.jumpTo(offset);
  }

  @override
  void didUpdateWidget(covariant _MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text && _scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                // Metin, önce ekranın tamamen dışından (sağdan) görünmeye
                // başlasın diye başına ekran genişliği kadar boşluk
                // ekleniyor.
                SizedBox(width: constraints.maxWidth),
                Text(
                  widget.text,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.0,
                  ),
                ),
                // Şerit bir tur tamamlayıp baştan başladığında araya
                // görsel bir boşluk koymak için.
                SizedBox(width: constraints.maxWidth * 0.5),
              ],
            ),
          ),
        );
      },
    );
  }
}
