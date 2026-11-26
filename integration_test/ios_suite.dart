import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test.dart';

import 'app_test.dart' as demo;
import 'starter_test.dart' as starter;

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Keep the OS from changing the semantics handle count during test startup.
  binding.platformDispatcher.semanticsEnabledTestValue = false;
  starter.main();
  demo.main();

  // Report directly from the app so CI does not need to attach to the VM.
  final passed = await binding.allTestsPassed.future;
  const runId = String.fromEnvironment('TEST_RUN_ID');
  final temp = Directory.systemTemp.path;
  final pending = File('$temp/starter-tests-$runId.pending');
  await pending.writeAsString(
    jsonEncode({
      'passed': passed,
      'results': binding.results.map(
        (name, result) => MapEntry(name, result.toString()),
      ),
    }),
  );
  await pending.rename('$temp/starter-tests-$runId.json');
}
