class Task {
  const Task({required this.id, required this.title, this.completed = false});

  final int id;
  final String title;
  final bool completed;
}

abstract interface class TaskRepository {
  Future<List<Task>> load();
  Future<List<Task>> add(String title);
  Future<List<Task>> setCompleted(int id, bool completed);
  Future<List<Task>> removeCompleted();
}

/// Seed data for running the template without an account or backend.
class LocalTaskRepository implements TaskRepository {
  final _tasks = [
    const Task(id: 1, title: 'Run the app on a device', completed: true),
    const Task(id: 2, title: 'Explore the component catalog'),
  ];
  var _nextId = 3;

  @override
  Future<List<Task>> load() async => List.unmodifiable(_tasks);

  @override
  Future<List<Task>> add(String title) async {
    _tasks.add(Task(id: _nextId++, title: title));
    return load();
  }

  @override
  Future<List<Task>> setCompleted(int id, bool completed) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    final task = _tasks[index];
    _tasks[index] = Task(id: task.id, title: task.title, completed: completed);
    return load();
  }

  @override
  Future<List<Task>> removeCompleted() async {
    _tasks.removeWhere((task) => task.completed);
    return load();
  }
}
