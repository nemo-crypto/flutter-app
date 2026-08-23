import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/card_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/card_art.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/section_title.dart';
import '../application/gacha_controller.dart';
import '../domain/gacha_models.dart';

class GachaPage extends StatelessWidget {
  const GachaPage({super.key, required this.controller});

  final GachaController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final catalog = controller.catalog;
        if (catalog == null) {
          return _LoadingState(
            isLoading: controller.isLoading,
            errorMessage: controller.errorMessage,
            onRetry: controller.retry,
          );
        }
        if (catalog.banners.isEmpty || catalog.cards.isEmpty) {
          return _LoadingState(
            isLoading: false,
            errorMessage: '服务端没有返回可用卡池数据',
            onRetry: controller.retry,
          );
        }
        return _GachaContent(controller: controller, catalog: catalog);
      },
    );
  }
}

class _GachaContent extends StatefulWidget {
  const _GachaContent({required this.controller, required this.catalog});

  final GachaController controller;
  final GachaCatalog catalog;

  @override
  State<_GachaContent> createState() => _GachaContentState();
}

class _GachaContentState extends State<_GachaContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _summonController;
  var _wasLoading = false;
  var _isSummoning = false;

  GachaController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _wasLoading = controller.isLoading;
    _summonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
      value: 1,
    );
    controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_handleControllerChanged);
    _summonController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    final isLoading = controller.isLoading;
    if (isLoading && !_wasLoading) {
      _isSummoning = true;
      _summonController.forward(from: 0);
      if (mounted) {
        setState(() {});
      }
    } else if (!isLoading && _wasLoading) {
      _revealSummon();
    }
    _wasLoading = isLoading;
  }

  Future<void> _revealSummon() async {
    await _summonController.animateTo(
      1,
      duration: const Duration(milliseconds: 980),
      curve: Curves.easeOutCubic,
    );
    if (mounted) {
      setState(() => _isSummoning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final banner = widget.catalog.banners[controller.selectedBannerIndex];
    final result = controller.lastResult ?? widget.catalog.cards.first;
    return CustomScrollView(
      key: const Key('page-gacha'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '抽卡中心',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '命运会回应每一次呼唤',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  GlassPanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    borderRadius: 14,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.brightness_5_outlined,
                          color: AppColors.gold,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${controller.pullCount}',
                          key: const Key('gacha-pull-count'),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _BannerSwitcher(
                selectedIndex: controller.selectedBannerIndex,
                banners: widget.catalog.banners,
                onChanged: controller.selectBanner,
              ),
              const SizedBox(height: 18),
              AnimatedBuilder(
                animation: _summonController,
                builder: (context, _) {
                  return _SummonStage(
                    result: result,
                    isLoading: controller.isLoading,
                    isSummoning: _isSummoning,
                    progress: _summonController.value,
                  );
                },
              ),
              const SizedBox(height: 16),
              GlassPanel(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.cyan,
                      size: 18,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        '${banner.title} · ${banner.subtitle}\nSSR 基础概率 1.2%，保底计数继承当前卡池。',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  controller.errorMessage!,
                  style: const TextStyle(color: AppColors.pink, fontSize: 11),
                ),
              ],
              const SizedBox(height: 24),
              const SectionTitle(title: '选择召唤方式'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _PullButton(
                      buttonKey: const Key('gacha-single'),
                      title: '单抽',
                      subtitle: '消耗 1 星尘',
                      icon: Icons.auto_awesome,
                      isLoading: controller.isLoading,
                      onPressed: () => controller.draw(tenPull: false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PullButton(
                      buttonKey: const Key('gacha-ten'),
                      title: '十连抽',
                      subtitle: '消耗 10 星尘',
                      icon: Icons.stars_rounded,
                      accent: AppColors.pink,
                      isLoading: controller.isLoading,
                      onPressed: () => controller.draw(tenPull: true),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

double _summonTimeline(
  double value,
  double begin,
  double end, [
  Curve curve = Curves.linear,
]) {
  if (value <= begin) {
    return 0;
  }
  if (value >= end) {
    return 1;
  }
  return curve.transform((value - begin) / (end - begin));
}

double _summonBurst(double value, double begin, double peak, double end) {
  if (value <= begin || value >= end) {
    return 0;
  }
  if (value <= peak) {
    return (value - begin) / (peak - begin);
  }
  return 1 - ((value - peak) / (end - peak));
}

class _SummonStage extends StatelessWidget {
  const _SummonStage({
    required this.result,
    required this.isLoading,
    required this.isSummoning,
    required this.progress,
  });

  final CardItem result;
  final bool isLoading;
  final bool isSummoning;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0).toDouble();
    final cardReveal = _summonTimeline(
      clampedProgress,
      0.58,
      0.96,
      Curves.easeOutBack,
    );
    final cardFlip = _summonTimeline(
      clampedProgress,
      0.5,
      0.82,
      Curves.easeInOutCubic,
    );
    final cardOpacity = isSummoning
        ? _summonTimeline(clampedProgress, 0.5, 0.64, Curves.easeOut)
        : 1.0;
    final flash = _summonBurst(clampedProgress, 0.66, 0.74, 0.92);
    final coreOpacity = isSummoning
        ? 1 - _summonTimeline(clampedProgress, 0.66, 0.88, Curves.easeIn)
        : 0.0;
    final cardChild = cardFlip < 0.5
        ? _CardBack(color: result.rarity.color)
        : CardArt(card: result, height: 270);
    final cardTransform = Matrix4.identity()
      ..setEntry(3, 2, 0.0018)
      ..rotateY((1 - cardFlip) * math.pi);
    final status = isLoading
        ? (clampedProgress < 0.24
              ? '召唤协议启动'
              : clampedProgress < 0.48
              ? '星门频率锁定'
              : '稀有度判定中')
        : '命运显现';

    return SizedBox(
      key: const Key('gacha-summon-stage'),
      height: 270,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _SummonEnergyPainter(
                  progress: clampedProgress,
                  active: isSummoning,
                  color: result.rarity.color,
                  rarity: result.rarity,
                ),
              ),
            ),
          ),
          Opacity(
            opacity: cardOpacity.clamp(0.0, 1.0),
            child: Transform(
              alignment: Alignment.center,
              transform: cardTransform,
              child: Transform.scale(
                scale: isSummoning
                    ? 0.78 + cardReveal.clamp(0.0, 1.0) * 0.22
                    : 1,
                child: cardChild,
              ),
            ),
          ),
          if (isSummoning)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.82,
                      colors: [
                        result.rarity.color.withValues(
                          alpha: 0.08 + flash * 0.3,
                        ),
                        AppColors.background.withValues(
                          alpha: 0.68 - flash * 0.5,
                        ),
                      ],
                      stops: const [0.08, 1],
                    ),
                  ),
                ),
              ),
            ),
          if (isSummoning)
            IgnorePointer(
              child: Opacity(
                opacity: coreOpacity.clamp(0.0, 1.0),
                child: _EnergyCore(
                  progress: clampedProgress,
                  color: result.rarity.color,
                ),
              ),
            ),
          if (isSummoning)
            Positioned(
              top: 13,
              left: 18,
              right: 18,
              child: IgnorePointer(
                child: _RitualReadout(
                  label: status,
                  progress: clampedProgress,
                  color: result.rarity.color,
                ),
              ),
            ),
          if (isSummoning)
            Positioned(
              left: 26,
              right: 26,
              bottom: 12,
              child: IgnorePointer(
                child: _RitualProgress(
                  progress: clampedProgress,
                  color: result.rarity.color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EnergyCore extends StatelessWidget {
  const _EnergyCore({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pulse = 0.9 + math.sin(progress * math.pi * 12).abs() * 0.14;
    return Transform.scale(
      scale: pulse,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.46),
                  blurRadius: 36,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white, color, color.withValues(alpha: 0.08)],
                stops: const [0, 0.22, 1],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.86),
                  blurRadius: 28,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummonEnergyPainter extends CustomPainter {
  const _SummonEnergyPainter({
    required this.progress,
    required this.active,
    required this.color,
    required this.rarity,
  });

  final double progress;
  final bool active;
  final Color color;
  final CardRarity rarity;

  @override
  void paint(Canvas canvas, Size size) {
    if (!active) {
      return;
    }
    final center = Offset(size.width / 2, size.height / 2);
    final pulse = (math.sin(progress * math.pi * 12) + 1) / 2;
    final maxRadius = math.min(size.width, size.height) * 0.72;
    final intensity = switch (rarity) {
      CardRarity.common => 0.78,
      CardRarity.rare => 0.9,
      CardRarity.epic => 1.08,
      CardRarity.legendary => 1.28,
    };
    final gateProgress = _summonTimeline(progress, 0.08, 0.68);
    final burst = _summonBurst(progress, 0.66, 0.74, 0.92);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(22)),
      Paint()..color = AppColors.background.withValues(alpha: 0.16),
    );

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.42 * intensity + pulse * 0.1),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));
    canvas.drawCircle(center, maxRadius, glowPaint);

    final starPaint = Paint()..strokeCap = StrokeCap.round;
    for (var index = 0; index < 38; index++) {
      final seed = index * 1.618;
      final angle = seed + progress * (0.5 + (index % 3) * 0.12);
      final distance =
          34 +
          ((index * 37) % 100) / 100 * maxRadius * (0.64 + gateProgress * 0.36);
      final twinkle =
          0.45 + (math.sin(progress * math.pi * 8 + seed) + 1) * 0.25;
      final point = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance * 0.58,
      );
      starPaint
        ..color = Colors.white.withValues(alpha: twinkle * 0.58)
        ..strokeWidth = index.isEven ? 1.8 : 1;
      canvas.drawLine(
        point - const Offset(3, 0),
        point + const Offset(3, 0),
        starPaint,
      );
      canvas.drawLine(
        point - const Offset(0, 3),
        point + const Offset(0, 3),
        starPaint,
      );
    }

    for (var index = 0; index < 4; index++) {
      final ringProgress = (progress * 1.16 + index * 0.19) % 1;
      final radius = 28 + ringProgress * maxRadius;
      final paint = Paint()
        ..color = color.withValues(
          alpha: (1 - ringProgress) * (0.54 + intensity * 0.12),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 + (1 - ringProgress) * 2.5;
      canvas.drawCircle(center, radius, paint);
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * math.pi * 0.7);
    canvas.scale(1, 0.42);
    for (var index = 0; index < 3; index++) {
      final radius = 42 + index * 22 + gateProgress * 30;
      final paint = Paint()
        ..color = color.withValues(alpha: 0.46 - index * 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = index == 0 ? 1.8 : 1;
      canvas.drawCircle(Offset.zero, radius, paint);
    }
    canvas.restore();

    final rayPaint = Paint()..strokeCap = StrokeCap.round;
    for (var index = 0; index < 28; index++) {
      final angle = index / 28 * math.pi * 2 + progress * math.pi * 1.6;
      final rayProgress = (progress * 1.7 + index * 0.071) % 1;
      final innerRadius = 30 + rayProgress * 42;
      final outerRadius = innerRadius + 12 + pulse * 34 * intensity;
      final start = Offset(
        center.dx + math.cos(angle) * innerRadius,
        center.dy + math.sin(angle) * innerRadius,
      );
      final end = Offset(
        center.dx + math.cos(angle) * outerRadius,
        center.dy + math.sin(angle) * outerRadius,
      );
      rayPaint
        ..color = (index % 5 == 0 ? Colors.white : color).withValues(
          alpha: (1 - rayProgress) * (0.52 + intensity * 0.16),
        )
        ..strokeWidth = index % 5 == 0 ? 2.2 : (index.isEven ? 1.5 : 0.8);
      canvas.drawLine(start, end, rayPaint);
    }

    final sealRadius = 54 + gateProgress * 26;
    final sealPaint = Paint()
      ..color = color.withValues(alpha: 0.62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    for (var index = 0; index < 16; index++) {
      final angle = index / 16 * math.pi * 2 - progress * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: sealRadius),
        angle,
        index.isEven ? 0.18 : 0.08,
        false,
        sealPaint,
      );
    }

    if (burst > 0) {
      final shockRadius = 32 + burst * maxRadius;
      final shockPaint = Paint()
        ..color = Colors.white.withValues(alpha: burst * 0.66)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + (1 - burst) * 5;
      canvas.drawCircle(center, shockRadius, shockPaint);

      final shardPaint = Paint()
        ..color = color.withValues(alpha: burst * 0.76)
        ..style = PaintingStyle.fill;
      for (var index = 0; index < 18; index++) {
        final angle = index / 18 * math.pi * 2 + progress * 0.4;
        final distance = 44 + burst * maxRadius * (0.65 + (index % 3) * 0.1);
        final point = Offset(
          center.dx + math.cos(angle) * distance,
          center.dy + math.sin(angle) * distance,
        );
        final tangent = Offset(-math.sin(angle), math.cos(angle));
        final path = Path()
          ..moveTo(point.dx, point.dy)
          ..lineTo(
            point.dx - math.cos(angle) * 7 + tangent.dx * 3,
            point.dy - math.sin(angle) * 7 + tangent.dy * 3,
          )
          ..lineTo(
            point.dx - math.cos(angle) * 18,
            point.dy - math.sin(angle) * 18,
          )
          ..close();
        canvas.drawPath(path, shardPaint);
      }

      final flashPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: burst * 0.62),
            color.withValues(alpha: burst * 0.22),
            Colors.transparent,
          ],
          stops: const [0, 0.16, 1],
        ).createShader(Rect.fromCircle(center: center, radius: maxRadius));
      canvas.drawCircle(center, maxRadius, flashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SummonEnergyPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.active != active ||
        oldDelegate.color != color ||
        oldDelegate.rarity != rarity;
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceLight,
            Color.lerp(AppColors.background, color, 0.25) ??
                AppColors.background,
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.72), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.34),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _CardBackPainter(color: color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_open_rounded, color: color, size: 32),
              const SizedBox(height: 10),
              Text(
                'NEMO',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'DESTINY ARCHIVE',
                style: TextStyle(
                  color: color.withValues(alpha: 0.82),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardBackPainter extends CustomPainter {
  const _CardBackPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.36;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var index = 0; index < 4; index++) {
      canvas.drawCircle(center, radius - index * 18, paint);
    }
    for (var index = 0; index < 12; index++) {
      final angle = index / 12 * math.pi * 2;
      final start = Offset(
        center.dx + math.cos(angle) * (radius - 28),
        center.dy + math.sin(angle) * (radius - 28),
      );
      final end = Offset(
        center.dx + math.cos(angle) * (radius + 3),
        center.dy + math.sin(angle) * (radius + 3),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CardBackPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _RitualReadout extends StatelessWidget {
  const _RitualReadout({
    required this.label,
    required this.progress,
    required this.color,
  });

  final String label;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pulse = 0.72 + math.sin(progress * math.pi * 10).abs() * 0.28;
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: pulse),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.7,
          ),
        ),
        const Spacer(),
        Text(
          '${(progress * 100).round().toString().padLeft(3, '0')}%',
          style: TextStyle(
            color: color.withValues(alpha: 0.9),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _RitualProgress extends StatelessWidget {
  const _RitualProgress({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'SYNC',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _BannerSwitcher extends StatelessWidget {
  const _BannerSwitcher({
    required this.selectedIndex,
    required this.banners,
    required this.onChanged,
  });

  final int selectedIndex;
  final List<GachaBanner> banners;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < banners.length; index++) ...[
          Expanded(
            child: InkWell(
              key: ValueKey('gacha-banner-${banners[index].id}'),
              onTap: () => onChanged(index),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? AppColors.purple.withValues(alpha: 0.22)
                      : AppColors.surface.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selectedIndex == index
                        ? AppColors.purple
                        : Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      banners[index].title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      banners[index].subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (index != banners.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _PullButton extends StatelessWidget {
  const _PullButton({
    required this.buttonKey,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
    this.accent = AppColors.cyan,
  });

  final Key buttonKey;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: buttonKey,
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: AppColors.background,
        disabledBackgroundColor: accent.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.background.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const CircularProgressIndicator(color: AppColors.cyan)
              else
                const Icon(
                  Icons.cloud_off_outlined,
                  color: AppColors.pink,
                  size: 32,
                ),
              const SizedBox(height: 14),
              Text(
                isLoading ? '正在同步星图…' : errorMessage ?? '暂无卡池数据',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!isLoading) ...[
                const SizedBox(height: 14),
                OutlinedButton(onPressed: onRetry, child: const Text('重新加载')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
