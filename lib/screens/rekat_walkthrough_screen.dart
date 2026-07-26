import 'package:flutter/material.dart';
import '../data/prayer_guide_data.dart';
import '../models/prayer_guide.dart';
import '../theme/app_theme.dart';
import '../widgets/pose_painter.dart';

class RekatWalkthroughScreen extends StatefulWidget {
  final String prayerName;
  final RekatGroup group;

  const RekatWalkthroughScreen({
    super.key,
    required this.prayerName,
    required this.group,
  });

  @override
  State<RekatWalkthroughScreen> createState() =>
      _RekatWalkthroughScreenState();
}

class _RekatWalkthroughScreenState extends State<RekatWalkthroughScreen> {
  late final List<PrayerStep> _steps;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _steps = generateSteps(widget.group);
  }

  void _next() {
    if (_index < _steps.length - 1) {
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
    final step = _steps[_index];
    final progress = (_index + 1) / _steps.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.prayerName} · ${widget.group.label}'),
      ),
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
                'Adım ${_index + 1} / ${_steps.length}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            Center(
              child: AnimatedPoseView(
                pose: step.pose,
                color: AppTheme.primaryGreen,
                size: 170,
              ),
            ),
            const SizedBox(height: 12),
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
                      onPressed: _index == _steps.length - 1
                          ? () => Navigator.pop(context)
                          : _next,
                      child: Text(
                        _index == _steps.length - 1 ? 'Tamamlandı' : 'İleri',
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
