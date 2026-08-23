import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/app_shell.dart';
import '../../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
    _contentAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.72, curve: Curves.easeOutCubic),
    );
    _openHomeAfterIntro();
  }

  Future<void> _openHomeAfterIntro() async {
    await Future<void>.delayed(const Duration(milliseconds: 2900));
    if (!mounted) {
      return;
    }
    _openHome();
  }

  void _openHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, animation, _) {
          final transition = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: transition,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.04, end: 1).animate(transition),
              child: const AppShell(),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _StarfieldPainter(progress: _controller.value),
              ),
              Positioned(
                top: 44,
                left: 28,
                right: 28,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusLabel(
                      icon: Icons.blur_on_rounded,
                      label: 'NEMO / ORBITAL',
                      color: AppColors.cyan,
                    ),
                    _StatusLabel(
                      icon: Icons.wifi_tethering_rounded,
                      label: 'LINK 01',
                      color: AppColors.pink,
                    ),
                  ],
                ),
              ),
              Center(
                child: FadeTransition(
                  opacity: _contentAnimation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.72,
                      end: 1,
                    ).animate(_contentAnimation),
                    child: _SplashContent(progress: _controller.value),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 26,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.46, 0.92),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              'INITIALIZING STAR ARCHIVE',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(_controller.value * 100).round().toString().padLeft(3, '0')}%',
                              style: const TextStyle(
                                color: AppColors.cyan,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: _controller.value,
                            minHeight: 2,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.cyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final rotation = progress * math.pi * 0.7;
    final pulse = 1 + math.sin(progress * math.pi * 8).abs() * 0.025;
    return Transform.scale(
      scale: pulse,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 236,
            height: 236,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(236),
                  painter: _OrbitPainter(progress: progress),
                ),
                Transform.rotate(
                  angle: rotation,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.36),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.18),
                          blurRadius: 22,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -rotation * 0.72,
                  child: Container(
                    width: 156,
                    height: 156,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.pink.withValues(alpha: 0.42),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                ClipOval(
                  child: SizedBox(
                    width: 112,
                    height: 112,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppColors.cyan, AppColors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Positioned(
                          left: -24,
                          right: -24,
                          top: 52 + math.sin(progress * math.pi * 4) * 18,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.9),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cyan.withValues(alpha: 0.8),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 46,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '星穹抽卡',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'COLLECT YOUR NEXT CONSTELLATION',
            style: TextStyle(
              color: AppColors.cyan.withValues(alpha: 0.78),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.72),
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.45;
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.cyan.withValues(alpha: 0.42);
    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = AppColors.pink.withValues(alpha: 0.72);

    canvas.drawCircle(center, radius, orbitPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 9),
      progress * math.pi * 2,
      math.pi * 0.52,
      false,
      accentPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 16),
      -progress * math.pi * 2.3,
      math.pi * 0.28,
      false,
      orbitPaint,
    );

    for (var index = 0; index < 8; index++) {
      final angle = progress * math.pi * 2 + index / 8 * math.pi * 2;
      final nodeRadius = radius + (index.isEven ? 10 : 17);
      final node = Offset(
        center.dx + math.cos(angle) * nodeRadius,
        center.dy + math.sin(angle) * nodeRadius,
      );
      final nodePaint = Paint()
        ..color = (index.isEven ? AppColors.cyan : AppColors.pink).withValues(
          alpha: 0.74,
        )
        ..style = PaintingStyle.fill;
      canvas.drawCircle(node, index.isEven ? 2.2 : 1.4, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _StarfieldPainter extends CustomPainter {
  const _StarfieldPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF050712), AppColors.background, Color(0xFF11112B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.purple.withValues(alpha: 0.18),
              AppColors.purple.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.width * 0.72),
          );
    canvas.drawCircle(center, size.width * 0.72, glowPaint);

    final gridPaint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    for (var index = 1; index < 8; index++) {
      final y = size.height * index / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.48);
    for (var index = 0; index < 86; index++) {
      final x = (index * 83.0 + 19) % size.width;
      final y = (index * 137.0 + 41) % size.height;
      final twinkle = (math.sin(progress * math.pi * 2 + index) + 1) / 2;
      final drift = math.sin(progress * math.pi * 2 + index * 0.37) * 4;
      canvas.drawCircle(Offset(x + drift, y), 0.45 + twinkle * 1.15, starPaint);
    }

    for (var index = 0; index < 4; index++) {
      final startX =
          (size.width * (0.08 + index * 0.27) +
                  progress * size.width * (0.24 + index * 0.04)) %
              (size.width + 100) -
          50;
      final startY = size.height * (0.18 + index * 0.16);
      final streakPaint = Paint()
        ..shader =
            LinearGradient(
              colors: [
                Colors.transparent,
                (index.isEven ? AppColors.cyan : AppColors.pink).withValues(
                  alpha: 0.34,
                ),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromPoints(
                Offset(startX, startY),
                Offset(startX + 90, startY - 32),
              ),
            )
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX + 90, startY - 32),
        streakPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
