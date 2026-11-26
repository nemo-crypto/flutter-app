import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/app/app.dart';

void main() {
  testWidgets('shows splash and enters the app shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GachaDemoApp());

    expect(find.text('星穹抽卡'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2900));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('探索'), findsOneWidget);
    expect(find.text('抽卡'), findsOneWidget);

    await tester.tap(find.text('抽卡'));
    await tester.pump();
    expect(find.text('抽卡中心'), findsOneWidget);

    await tester.tap(find.text('收藏'));
    await tester.pump();
    expect(find.text('星辉图鉴'), findsOneWidget);

    await tester.tap(find.text('我的'));
    await tester.pump();
    expect(find.text('我的航线'), findsOneWidget);
  });
}
