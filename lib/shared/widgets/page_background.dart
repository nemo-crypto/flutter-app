import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PageBackground extends StatelessWidget {
  const PageBackground({
    super.key,
    required this.child,
    this.topColor = AppColors.purple,
  });

  final Widget child;
  final Color topColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      tween: ColorTween(end: topColor),
      builder: (context, animatedColor, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PageGlowPainter(topColor: animatedColor ?? topColor),
              ),
            ),
            child!,
          ],
        );
      },
      child: child,
    );
  }
}

class _PageGlowPainter extends CustomPainter {
  const _PageGlowPainter({required this.topColor});

  final Color topColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              topColor.withValues(alpha: 0.22),
              topColor.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.78, size.height * 0.02),
              radius: size.width * 0.82,
            ),
          );
    canvas.drawRect(Offset.zero & size, paint);

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    for (var index = 0; index < 22; index++) {
      final x = (index * 71.0) % size.width;
      final y = (index * 127.0 + 42) % size.height;
      canvas.drawCircle(Offset(x, y), index.isEven ? 1.2 : 0.7, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PageGlowPainter oldDelegate) {
    return oldDelegate.topColor != topColor;
  }
}
