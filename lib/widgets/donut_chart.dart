import 'package:flutter/material.dart';

class DonutSlice {
  final String label;
  final int value;
  final Color color;
  DonutSlice({required this.label, required this.value, required this.color});
}

/// رسم بياني دائري (donut) بسيط بدون مكتبة خارجية، مع مفتاح ألوان (legend).
class DonutChart extends StatelessWidget {
  final List<DonutSlice> slices;
  final double size;

  const DonutChart({super.key, required this.slices, this.size = 130});

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<int>(0, (sum, s) => sum + s.value);

    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _DonutPainter(slices: slices, total: total),
            child: Center(
              child: Text(
                '$total',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: slices.map((s) {
              final pct = total == 0 ? 0 : (s.value / total * 100);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(s.label, style: const TextStyle(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis),
                    ),
                    Text('${pct.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSlice> slices;
  final int total;

  _DonutPainter({required this.slices, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final strokeWidth = size.width * 0.22;
    if (total == 0) {
      final paint = Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect.deflate(strokeWidth / 2), 0, 6.28319, false, paint);
      return;
    }
    double startAngle = -1.5708; // -90deg
    for (final s in slices) {
      final sweep = (s.value / total) * 6.28319;
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect.deflate(strokeWidth / 2), startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}
