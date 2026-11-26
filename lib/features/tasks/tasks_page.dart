import 'package:flutter/material.dart';

import '../../ui/starter_ui.dart';
import 'tasks_controller.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.controller});

  final TasksController controller;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (widget.controller.busy || !_form.currentState!.validate()) return;
    final saved = await widget.controller.add(_title.text.trim());
    if (!mounted || !saved) return;
    _title.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _removeCompleted() async {
    final confirmed = await showAppConfirmation(
      context,
      title: 'Remove completed tasks?',
      message: 'Completed tasks will be removed from this list.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (mounted && confirmed) await widget.controller.removeCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final tasks = controller.tasks;
        return AppPage(
          title: 'Tasks',
          subtitle: 'A sample workflow with form validation and local data.',
          children: [
            if (tasks == null)
              if (controller.failed)
                AppMessage(
                  icon: Icons.error_outline,
                  title: 'Could not load tasks',
                  actionLabel: 'Retry',
                  onAction: controller.load,
                )
              else
                const AppLoading(label: 'Loading tasks'),
            if (tasks != null) ...[
              Form(
                key: _form,
                child: TextFormField(
                  key: const Key('task-title'),
                  controller: _title,
                  readOnly: controller.busy,
                  maxLength: 80,
                  decoration: const InputDecoration(labelText: 'Task title'),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _add(),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Enter a task title'
                      : null,
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilledButton.icon(
                  key: const Key('task-add'),
                  onPressed: controller.busy ? null : _add,
                  icon: const Icon(Icons.add),
                  label: const Text('Add task'),
                ),
              ),
              if (controller.busy)
                const LinearProgressIndicator(semanticsLabel: 'Saving tasks'),
              if (controller.failed)
                const AppMessage(
                  icon: Icons.error_outline,
                  title: 'Could not save the change',
                  detail: 'Try the action again.',
                ),
              const SizedBox(height: AppSpacing.medium),
              if (tasks.isEmpty)
                const AppMessage(
                  icon: Icons.inbox_outlined,
                  title: 'No tasks yet',
                ),
              for (final task in tasks)
                CheckboxListTile(
                  key: ValueKey(task.id),
                  contentPadding: EdgeInsets.zero,
                  title: Text(task.title),
                  value: task.completed,
                  onChanged: controller.busy
                      ? null
                      : (_) => controller.toggle(task),
                ),
              if (tasks.any((task) => task.completed))
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: controller.busy ? null : _removeCompleted,
                    child: const Text('Remove completed'),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}
