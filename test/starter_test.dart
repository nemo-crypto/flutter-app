import 'package:flutter/material.dart';
import 'package:flutter_starter/app/starter_app.dart';
import 'package:flutter_starter/features/tasks/task_repository.dart';
import 'package:flutter_starter/ui/starter_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('load failure is recoverable and navigation adapts', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(StarterApp(taskRepository: _RetryRepository()));
    await tester.pumpAndSettle();
    expect(find.text('Could not load tasks'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('task-title')), findsOneWidget);

    tester.view.physicalSize = const Size(1024, 768);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);

    await tester.tap(find.byKey(const Key('rail-components')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Error'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load items'), findsOneWidget);
  });

  testWidgets('shared animations follow system reduced motion', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: AppAnimatedSize(
            child: AppAnimatedContent(child: Text('Content')),
          ),
        ),
      ),
    );

    expect(
      tester.widget<AnimatedSize>(find.byType(AnimatedSize)).duration,
      Duration.zero,
    );
    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      Duration.zero,
    );
  });
}

class _RetryRepository extends LocalTaskRepository {
  var _attempts = 0;

  @override
  Future<List<Task>> load() {
    if (_attempts++ == 0) return Future.error(StateError('Offline'));
    return super.load();
  }
}
