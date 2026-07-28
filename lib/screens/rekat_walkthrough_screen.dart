import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../data/prayer_guide_data.dart';
import '../models/prayer_guide.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner_widget.dart';
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

  final FlutterTts _tts = FlutterTts();
  bool _isNarrating = false;
  bool _ttsReady = false;

  @override
  void initState() {
    super.initState();
    _steps = generateSteps(widget.group);
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('tr-TR');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(_onSpeechComplete);
      _ttsReady = true;
    } catch (_) {
      _ttsReady = false;
    }
  }

  void _onSpeechComplete() {
    if (!mounted || !_isNarrating) return;
    if (_index < _steps.length - 1) {
      setState(() => _index++);
      _speakCurrentStep();
    } else {
      setState(() => _isNarrating = false);
    }
  }

  Future<void> _speakCurrentStep() async {
    final step = _steps[_index];
    await _tts.speak('${step.title}. ${step.description}');
  }

  Future<void> _toggleNarration() async {
    if (!_ttsReady) return;
    if (_isNarrating) {
      await _tts.stop();
      setState(() => _isNarrating = false);
    } else {
      setState(() => _isNarrating = true);
      _speakCurrentStep();
    }
  }

  Future<void> _stopNarrationIfActive() async {
    if (_isNarrating) {
      await _tts.stop();
      setState(() => _isNarrating = false);
    }
  }

  void _next() {
    _stopNarrationIfActive();
    if (_index < _steps.length - 1) {
      setState(() => _index++);
    }
  }

  void _prev() {
    _stopNarrationIfActive();
    if (_index > 0) {
      setState(() => _index--);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_index];
    final progress = (_index + 1) / _steps.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.prayerName} · ${widget.group.label}'),
      ),
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
                'Adım ${_index + 1} / ${_steps.length}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            Center(
              child: AnimatedPoseView(
                pose: step.pose,
                color: AppTheme.primaryGreen,
                size: 150,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _ttsReady ? _toggleNarration : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isNarrating ? Colors.redAccent : AppTheme.accentGold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: Icon(
                _isNarrating ? Icons.stop_circle : Icons.volume_up,
                size: 20,
              ),
              label: Text(
                _isNarrating ? 'Anlatımı Durdur' : 'Sesli Dinle',
              ),
            ),
            const SizedBox(height: 8),
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
