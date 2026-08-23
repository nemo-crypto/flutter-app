import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_theme.dart';
import 'app_shell.dart';
import '../features/splash/presentation/splash_page.dart';

class GachaDemoApp extends StatelessWidget {
  const GachaDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '星穹抽卡',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AppConfig.skipSplash ? const AppShell() : const SplashPage(),
    );
  }
}
