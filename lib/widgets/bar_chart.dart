import 'package:flutter/material.dart';

/// رسم بياني بسيط بالأعمدة (bar chart) بدون مكتبة خارجية.
class SimpleBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final double height;

  const SimpleBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final maxV = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxV <= 0 ? 1.0 : maxV;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final ratio = values[i] / safeMax;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    values[i] == 0 ? '' : values[i].toStringAsFixed(0),
                    style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    height: (height - 36) * ratio.clamp(0.0, 1.0) + 4,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.85),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    i < labels.length ? labels[i] : '',
                    style: const TextStyle(color: Colors.grey, fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
