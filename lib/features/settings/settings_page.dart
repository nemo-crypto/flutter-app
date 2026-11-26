import 'package:flutter/material.dart';

import '../../ui/starter_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Settings',
    children: [
      AppPanel(
        child: RadioGroup<ThemeMode>(
          groupValue: themeMode,
          onChanged: (mode) {
            if (mode != null) onThemeChanged(mode);
          },
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appearance'),
              RadioListTile(value: ThemeMode.system, title: Text('System')),
              RadioListTile(value: ThemeMode.light, title: Text('Light')),
              RadioListTile(value: ThemeMode.dark, title: Text('Dark')),
            ],
          ),
        ),
      ),
    ],
  );
}
