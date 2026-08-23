import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:unravel/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('完成启动动画并验证四个 Tab 的核心流程', (tester) async {
    await tester.pumpWidget(const GachaDemoApp());

    // 默认启动动画约 2.9 秒，额外等待路由淡入和卡池 Mock 请求。
    await tester.pump(const Duration(milliseconds: 3700));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tab-explore')), findsOneWidget);
    expect(find.byKey(const Key('tab-gacha')), findsOneWidget);
    expect(find.byKey(const Key('tab-collection')), findsOneWidget);
    expect(find.byKey(const Key('tab-profile')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tab-gacha')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-gacha')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('gacha-single')),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('gacha-single')), findsOneWidget);
    expect(find.byKey(const Key('gacha-ten')), findsOneWidget);

    await tester.tap(find.byKey(const Key('gacha-single')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('gacha-pull-count')),
      -320,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('gacha-pull-count')), findsOneWidget);
    expect(find.text('43'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('gacha-ten')),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('gacha-ten')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('gacha-pull-count')),
      -320,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('53'), findsOneWidget);
    expect(find.text('月面信使'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tab-collection')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-collection')), findsOneWidget);

    await tester.tap(find.byKey(const Key('rarity-filter-SSR')));
    await tester.pumpAndSettle();
    expect(find.text('极光观测者'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tab-profile')));
    await tester.pumpAndSettle();
    expect(find.text('我的航线'), findsOneWidget);
  });
}
