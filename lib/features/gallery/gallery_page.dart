import 'package:flutter/material.dart';

import '../../ui/starter_ui.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  var _state = 'Empty';
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Components',
      subtitle: 'Preview shared controls, feedback states and motion.',
      children: [
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Actions', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: [
                  FilledButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Action completed')),
                    ),
                    child: const Text('Show feedback'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final confirmed = await showAppConfirmation(
                        context,
                        title: 'Confirm action?',
                        message: 'This dialog follows the device platform.',
                        confirmLabel: 'Confirm',
                      );
                      if (context.mounted && confirmed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Confirmed')),
                        );
                      }
                    },
                    child: const Text('Open dialog'),
                  ),
                  const FilledButton(onPressed: null, child: Text('Disabled')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Feedback', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: AppSpacing.small,
                children: [
                  for (final state in const ['Empty', 'Loading', 'Error'])
                    ChoiceChip(
                      label: Text(state),
                      selected: state == _state,
                      onSelected: (_) => setState(() => _state = state),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              AppAnimatedContent(
                child: switch (_state) {
                  'Loading' => const AppLoading(key: ValueKey('loading')),
                  'Error' => AppMessage(
                    key: const ValueKey('error'),
                    icon: Icons.error_outline,
                    title: 'Could not load items',
                    actionLabel: 'Retry',
                    onAction: () => setState(() => _state = 'Empty'),
                  ),
                  _ => const AppMessage(
                    key: ValueKey('empty'),
                    icon: Icons.inbox_outlined,
                    title: 'No items yet',
                  ),
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile.adaptive(
                title: const Text('Reveal content'),
                contentPadding: EdgeInsets.zero,
                value: _expanded,
                onChanged: (value) => setState(() => _expanded = value),
              ),
              AppAnimatedSize(
                child: _expanded
                    ? const Text(
                        'Motion follows your device accessibility settings.',
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
