import 'package:flutter/material.dart';
import '../models/prayer_guide.dart';

/// Her poz için vücut noktalarının 100x140'lık bir kutu içindeki konumu
/// (yandan görünüş - profilden namaz duruşu).
class _PosePoints {
  final Offset head;
  final Offset neck;
  final Offset hip;
  final Offset hand;
  final Offset knee;
  final Offset foot;

  const _PosePoints({
    required this.head,
    required this.neck,
    required this.hip,
    required this.hand,
    required this.knee,
    required this.foot,
  });

  static _PosePoints lerp(_PosePoints a, _PosePoints b, double t) {
    return _PosePoints(
      head: Offset.lerp(a.head, b.head, t)!,
      neck: Offset.lerp(a.neck, b.neck, t)!,
      hip: Offset.lerp(a.hip, b.hip, t)!,
      hand: Offset.lerp(a.hand, b.hand, t)!,
      knee: Offset.lerp(a.knee, b.knee, t)!,
      foot: Offset.lerp(a.foot, b.foot, t)!,
    );
  }
}

const Map<PoseType, _PosePoints> _poses = {
  PoseType.kiyam: _PosePoints(
    head: Offset(50, 15),
    neck: Offset(50, 26),
    hip: Offset(50, 75),
    hand: Offset(55, 55),
    knee: Offset(50, 105),
    foot: Offset(50, 135),
  ),
  PoseType.ruku: _PosePoints(
    head: Offset(88, 58),
    neck: Offset(78, 60),
    hip: Offset(50, 63),
    hand: Offset(80, 82),
    knee: Offset(50, 105),
    foot: Offset(50, 135),
  ),
  PoseType.secde: _PosePoints(
    head: Offset(78, 118),
    neck: Offset(66, 116),
    hip: Offset(48, 98),
    hand: Offset(72, 120),
    knee: Offset(48, 118),
    foot: Offset(33, 133),
  ),
  PoseType.oturus: _PosePoints(
    head: Offset(50, 58),
    neck: Offset(50, 70),
    hip: Offset(50, 100),
    hand: Offset(56, 88),
    knee: Offset(50, 118),
    foot: Offset(38, 128),
  ),
};

class PosePainter extends CustomPainter {
  final PoseType from;
  final PoseType to;
  final double t; // 0 -> from pozu, 1 -> to pozu
  final Color color;

  PosePainter({
    required this.from,
    required this.to,
    required this.t,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100;
    final p = _PosePoints.lerp(_poses[from]!, _poses[to]!, t);

    Offset s(Offset o) => Offset(o.dx * scale, o.dy * scale);

    final bodyPaint = Paint()
      ..color = color
      ..strokeWidth = 5 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final headPaint = Paint()..color = color;

    // Gövde: boyun -> kalça
    canvas.drawLine(s(p.neck), s(p.hip), bodyPaint);
    // Kol: boyun -> el
    canvas.drawLine(s(p.neck), s(p.hand), bodyPaint);
    // Bacak: kalça -> diz -> ayak
    canvas.drawLine(s(p.hip), s(p.knee), bodyPaint);
    canvas.drawLine(s(p.knee), s(p.foot), bodyPaint);
    // Baş
    canvas.drawCircle(s(p.head), 9 * scale, headPaint);

    // Zemin çizgisi
    final groundPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, size.height - 2),
      Offset(size.width, size.height - 2),
      groundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.from != from ||
        oldDelegate.to != to ||
        oldDelegate.t != t ||
        oldDelegate.color != color;
  }
}

/// Bir pozdan diğerine yumuşakça geçiş yapan animasyonlu figür widget'ı.
class AnimatedPoseView extends StatefulWidget {
  final PoseType pose;
  final Color color;
  final double size;

  const AnimatedPoseView({
    super.key,
    required this.pose,
    required this.color,
    this.size = 180,
  });

  @override
  State<AnimatedPoseView> createState() => _AnimatedPoseViewState();
}

class _AnimatedPoseViewState extends State<AnimatedPoseView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late PoseType _from;
  late PoseType _to;

  @override
  void initState() {
    super.initState();
    _from = widget.pose;
    _to = widget.pose;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..value = 1.0;
  }

  @override
  void didUpdateWidget(covariant AnimatedPoseView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pose != widget.pose) {
      _from = oldWidget.pose;
      _to = widget.pose;
      _controller
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 1.4,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: PosePainter(
              from: _from,
              to: _to,
              t: Curves.easeInOut.transform(_controller.value),
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}
