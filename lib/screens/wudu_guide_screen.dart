import 'package:flutter/material.dart';
import '../data/wudu_guide_data.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner_widget.dart';

class WuduGuideScreen extends StatefulWidget {
  const WuduGuideScreen({super.key});

  @override
  State<WuduGuideScreen> createState() => _WuduGuideScreenState();
}

class _WuduGuideScreenState extends State<WuduGuideScreen> {
  int _index = 0;

  void _next() {
    if (_index < wuduSteps.length - 1) {
      setState(() => _index++);
    }
  }

  void _prev() {
    if (_index > 0) {
      setState(() => _index--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = wuduSteps[_index];
    final progress = (_index + 1) / wuduSteps.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Abdest Alma Rehberi')),
      bottomNavigationBar: const AdBannerWidget(),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.grey.shade200,
              color: AppTheme.accentGold,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Adım ${_index + 1} / ${wuduSteps.length}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Container(
                key: ValueKey(_index),
                width: 130,
                height: 130,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(step.icon, color: Colors.white, size: 60),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      step.description,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _index == 0 ? null : _prev,
                      child: const Text('Geri'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _index == wuduSteps.length - 1
                          ? () => Navigator.pop(context)
                          : _next,
                      child: Text(
                        _index == wuduSteps.length - 1
                            ? 'Tamamlandı'
                            : 'İleri',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
