import 'package:flutter/material.dart';

import '../theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF14B8A6), AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const CustomPaint(painter: PulsePainter()),
        ),
        const SizedBox(width: 12),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'MediScan'),
              TextSpan(text: 'AI', style: TextStyle(color: AppColors.primary)),
            ],
          ),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
      ],
    );
  }
}

/// Tracé d'électrocardiogramme de l'icône de l'application.
class PulsePainter extends CustomPainter {
  const PulsePainter();

  // Points sur la zone 72 x 72 de l'icône (décalée de 18).
  static const _points = [
    Offset(12, 38), Offset(25, 38), Offset(30, 26), Offset(37, 50),
    Offset(43, 20), Offset(48, 38), Offset(60, 38),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 72;
    final path = Path()..moveTo(_points.first.dx * k, _points.first.dy * k);
    for (final p in _points.skip(1)) {
      path.lineTo(p.dx * k, p.dy * k);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(PulsePainter oldDelegate) => false;
}
