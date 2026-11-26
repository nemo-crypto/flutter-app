import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const short = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 280);

  static Duration duration(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}

/// Animate changes in the child's type or key.
class AppAnimatedContent extends StatelessWidget {
  const AppAnimatedContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.duration(context, AppMotion.standard),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(0, .06), end: Offset.zero),
          ),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Expand or collapse content while respecting system motion preferences.
class AppAnimatedSize extends StatelessWidget {
  const AppAnimatedSize({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: AppMotion.duration(context, AppMotion.standard),
    alignment: Alignment.topCenter,
    curve: Curves.easeOutCubic,
    child: child,
  );
}
