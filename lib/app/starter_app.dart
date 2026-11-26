import 'package:flutter/material.dart';

import '../features/gallery/gallery_page.dart';
import '../features/settings/settings_page.dart';
import '../features/tasks/task_repository.dart';
import '../features/tasks/tasks_controller.dart';
import '../features/tasks/tasks_page.dart';
import '../ui/starter_theme.dart';

class StarterApp extends StatefulWidget {
  const StarterApp({super.key, this.taskRepository});

  final TaskRepository? taskRepository;

  @override
  State<StarterApp> createState() => _StarterAppState();
}

class _StarterAppState extends State<StarterApp> {
  late final _controller = TasksController(
    widget.taskRepository ?? LocalTaskRepository(),
  )..load();
  var _themeMode = ThemeMode.system;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flutter Starter',
    debugShowCheckedModeBanner: false,
    theme: StarterTheme.build(Brightness.light),
    darkTheme: StarterTheme.build(Brightness.dark),
    themeMode: _themeMode,
    home: _StarterShell(
      pages: [
        TasksPage(controller: _controller),
        const GalleryPage(),
        SettingsPage(
          themeMode: _themeMode,
          onThemeChanged: (mode) => setState(() => _themeMode = mode),
        ),
      ],
    ),
  );
}

class _StarterShell extends StatefulWidget {
  const _StarterShell({required this.pages});

  final List<Widget> pages;

  @override
  State<_StarterShell> createState() => _StarterShellState();
}

class _StarterShellState extends State<_StarterShell> {
  static const _destinations = [
    (id: 'tasks', label: 'Tasks', icon: Icons.checklist_outlined),
    (id: 'components', label: 'Components', icon: Icons.widgets_outlined),
    (id: 'settings', label: 'Settings', icon: Icons.settings_outlined),
  ];
  var _selected = 0;

  void _select(int index) {
    if (index == _selected) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selected = index);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Starter'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: SafeArea(
        bottom: wide,
        child: Row(
          children: [
            if (wide) ...[
              NavigationRail(
                selectedIndex: _selected,
                onDestinationSelected: _select,
                labelType: NavigationRailLabelType.all,
                scrollable: true,
                destinations: [
                  for (final item in _destinations)
                    NavigationRailDestination(
                      icon: Icon(item.icon, key: Key('rail-${item.id}')),
                      label: Text(item.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
            ],
            Expanded(
              child: IndexedStack(
                index: _selected,
                children: [
                  for (var index = 0; index < widget.pages.length; index++)
                    TickerMode(
                      enabled: index == _selected,
                      child: ExcludeFocus(
                        excluding: index != _selected,
                        child: widget.pages[index],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selected,
              onDestinationSelected: _select,
              destinations: [
                for (final item in _destinations)
                  NavigationDestination(
                    key: Key('nav-${item.id}'),
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
              ],
            ),
    );
  }
}
