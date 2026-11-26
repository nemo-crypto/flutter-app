import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_starter/app/starter_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('add, complete and clear a task, then change theme', (
    tester,
  ) async {
    await tester.pumpWidget(const StarterApp());
    await tester.pumpAndSettle();

    final title = find.byKey(const Key('task-title'));
    final add = find.byKey(const Key('task-add'));
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.text('Enter a task title'), findsOneWidget);

    await tester.enterText(title, 'Device smoke test');
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();

    final task = find.widgetWithText(CheckboxListTile, 'Device smoke test');
    await tester.ensureVisible(task);
    await tester.tap(task);
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(task).value, isTrue);

    final remove = find.widgetWithText(TextButton, 'Remove completed');
    final cancel = find.text('Cancel');
    await tester.ensureVisible(remove);
    await tester.tap(remove.hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(task, findsOneWidget);

    // Live devices can keep a modal barrier during the exit transition.
    for (var attempt = 0; attempt < 40; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (cancel.evaluate().isNotEmpty) continue;
      await Scrollable.ensureVisible(tester.element(remove), alignment: 0.5);
      if (remove.hitTestable().evaluate().isNotEmpty) break;
    }
    expect(cancel, findsNothing);
    expect(remove.hitTestable(), findsOneWidget);
    await tester.tap(remove.hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(task, findsNothing);

    final wide =
        tester.view.physicalSize.width / tester.view.devicePixelRatio >= 720;
    await tester.tap(find.byKey(Key(wide ? 'rail-settings' : 'nav-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
