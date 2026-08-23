import 'package:flutter/material.dart';

import 'app_bootstrap.dart';
import '../core/theme/app_colors.dart';
import '../features/gacha/application/gacha_controller.dart';
import '../features/gacha/data/gacha_repository.dart';
import '../features/collection/presentation/collection_page.dart';
import '../features/gacha/presentation/gacha_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../shared/widgets/app_bottom_bar.dart';
import '../shared/widgets/page_background.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.repository});

  final GachaRepository? repository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  var _currentIndex = 0;
  var _previousIndex = 0;
  var _isPageTransitioning = false;
  var _transitionId = 0;
  late final GachaController _gachaController;
  late final List<Widget?> _pages;
  late final AnimationController _pageTransitionController;
  late final CurvedAnimation _pageTransitionAnimation;

  @override
  void initState() {
    super.initState();
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _pageTransitionAnimation = CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic,
    );
    _gachaController = GachaController(
      repository: widget.repository ?? AppBootstrap.createGachaRepository(),
    )..initialize();
    _pages = List<Widget?>.filled(4, null)..[0] = const HomePage();
  }

  @override
  void dispose() {
    _pageTransitionAnimation.dispose();
    _pageTransitionController.dispose();
    _gachaController.dispose();
    super.dispose();
  }

  Widget _buildPage(int index) {
    return switch (index) {
      0 => const HomePage(),
      1 => GachaPage(controller: _gachaController),
      2 => CollectionPage(controller: _gachaController),
      3 => const ProfilePage(),
      _ => const SizedBox.shrink(),
    };
  }

  void _selectPage(int index) {
    if (index == _currentIndex) {
      return;
    }

    _pages[index] ??= _buildPage(index);
    final transitionId = ++_transitionId;
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
      _isPageTransitioning = true;
    });

    _pageTransitionController.forward(from: 0).whenComplete(() {
      if (!mounted || transitionId != _transitionId) {
        return;
      }
      setState(() => _isPageTransitioning = false);
    });
  }

  Widget _buildPageStack() {
    final currentPage = _pages[_currentIndex] ?? const SizedBox.shrink();
    final previousPage = _pages[_previousIndex];
    final direction = _currentIndex > _previousIndex ? 1.0 : -1.0;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _pageTransitionController,
        builder: (context, child) {
          final progress = _isPageTransitioning
              ? _pageTransitionAnimation.value
              : 1.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              for (var index = 0; index < _pages.length; index++)
                if (_pages[index] != null &&
                    index != _currentIndex &&
                    (!_isPageTransitioning || index != _previousIndex))
                  Offstage(
                    child: TickerMode(enabled: false, child: _pages[index]!),
                  ),
              if (_isPageTransitioning && previousPage != null)
                _PageTransitionLayer(
                  page: previousPage,
                  opacity: 1 - progress,
                  offset: Offset(-direction * 0.035 * progress, 0),
                  scale: 1 - (0.006 * progress),
                  tickerEnabled: false,
                ),
              _PageTransitionLayer(
                page: currentPage,
                opacity: progress,
                offset: Offset(direction * 0.08 * (1 - progress), 0),
                scale: 0.985 + (0.015 * progress),
                tickerEnabled: true,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageBackground(
        topColor: _currentIndex == 1 ? AppColors.cyan : AppColors.purple,
        child: SafeArea(bottom: false, child: _buildPageStack()),
      ),
      bottomNavigationBar: AppBottomBar(
        currentIndex: _currentIndex,
        onChanged: _selectPage,
      ),
    );
  }
}

class _PageTransitionLayer extends StatelessWidget {
  const _PageTransitionLayer({
    required this.page,
    required this.opacity,
    required this.offset,
    required this.scale,
    required this.tickerEnabled,
  });

  final Widget page;
  final double opacity;
  final Offset offset;
  final double scale;
  final bool tickerEnabled;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !tickerEnabled,
      child: TickerMode(
        enabled: tickerEnabled,
        child: FractionalTranslation(
          translation: offset,
          child: Transform.scale(
            alignment: Alignment.center,
            scale: scale,
            child: Opacity(opacity: opacity.clamp(0, 1), child: page),
          ),
        ),
      ),
    );
  }
}
