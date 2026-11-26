import 'package:flutter/foundation.dart';

import 'task_repository.dart';

class TasksController extends ChangeNotifier {
  TasksController(this._repository);

  final TaskRepository _repository;
  List<Task>? _tasks;
  bool _busy = false;
  bool _failed = false;
  bool _disposed = false;

  List<Task>? get tasks => _tasks;
  bool get busy => _busy;
  bool get failed => _failed;

  Future<bool> load() => _run(_repository.load);
  Future<bool> add(String title) => _run(() => _repository.add(title));
  Future<bool> toggle(Task task) =>
      _run(() => _repository.setCompleted(task.id, !task.completed));
  Future<bool> removeCompleted() => _run(_repository.removeCompleted);

  Future<bool> _run(Future<List<Task>> Function() operation) async {
    if (_busy || _disposed) return false;
    _busy = true;
    _failed = false;
    notifyListeners();
    try {
      _tasks = List.unmodifiable(await operation());
      return true;
    } catch (_) {
      _failed = true;
      return false;
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
