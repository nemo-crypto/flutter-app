import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/data/demo_data.dart';
import 'package:flutter_starter/features/gacha/application/gacha_controller.dart';
import 'package:flutter_starter/features/gacha/data/gacha_repository.dart';
import 'package:flutter_starter/features/gacha/domain/gacha_models.dart';

void main() {
  group('GachaController', () {
    test('只加载一次卡池并设置首张推荐卡', () async {
      final repository = FakeGachaRepository();
      final controller = GachaController(repository: repository);
      addTearDown(controller.dispose);

      await Future.wait([controller.initialize(), controller.initialize()]);

      expect(repository.loadCalls, 1);
      expect(controller.catalog, isNotNull);
      expect(controller.lastResult?.id, DemoData.featuredCard.id);
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
    });

    test('加载失败后可以通过 retry 重新加载', () async {
      final repository = FakeGachaRepository(failLoad: true);
      final controller = GachaController(repository: repository);
      addTearDown(controller.dispose);

      await controller.initialize();
      expect(controller.catalog, isNull);
      expect(controller.errorMessage, '卡池加载失败，请稍后重试');

      repository.failLoad = false;
      await controller.retry();

      expect(repository.loadCalls, 2);
      expect(controller.catalog, isNotNull);
      expect(controller.errorMessage, isNull);
    });

    test('单抽和十连会传递正确的请求参数并更新结果', () async {
      final repository = FakeGachaRepository();
      final controller = GachaController(repository: repository);
      addTearDown(controller.dispose);
      await controller.initialize();

      await controller.draw(tenPull: false);
      expect(repository.drawCalls, 1);
      expect(repository.lastBannerId, 'deep-space-echo');
      expect(repository.lastTenPull, isFalse);
      expect(controller.pullCount, 43);
      expect(controller.lastResult?.id, DemoData.featuredCard.id);

      await controller.draw(tenPull: true);
      expect(repository.drawCalls, 2);
      expect(repository.lastTenPull, isTrue);
      expect(controller.pullCount, 53);
      expect(controller.lastResult?.id, 'lunar');
    });

    test('请求进行中会忽略重复抽卡操作', () async {
      final repository = FakeGachaRepository(
        drawDelay: const Duration(milliseconds: 20),
      );
      final controller = GachaController(repository: repository);
      addTearDown(controller.dispose);
      await controller.initialize();

      final firstDraw = controller.draw(tenPull: false);
      final secondDraw = controller.draw(tenPull: true);
      await Future.wait([firstDraw, secondDraw]);

      expect(repository.drawCalls, 1);
      expect(repository.lastTenPull, isFalse);
    });
  });
}

class FakeGachaRepository implements GachaRepository {
  FakeGachaRepository({
    this.failLoad = false,
    this.failDraw = false,
    this.drawDelay = Duration.zero,
  });

  bool failLoad;
  bool failDraw;
  final Duration drawDelay;
  var loadCalls = 0;
  var drawCalls = 0;
  String? lastBannerId;
  bool? lastTenPull;

  @override
  Future<GachaCatalog> loadCatalog() async {
    loadCalls++;
    if (failLoad) {
      throw StateError('load failed');
    }
    return const GachaCatalog(
      banners: [
        GachaBanner(
          id: 'deep-space-echo',
          title: '深空回响',
          subtitle: '极光观测者 · 概率提升',
        ),
        GachaBanner(
          id: 'lunar-archive',
          title: '月面档案',
          subtitle: '月面信使 · 限定复刻',
        ),
      ],
      cards: DemoData.cards,
    );
  }

  @override
  Future<GachaDrawResult> draw({
    required String bannerId,
    required bool tenPull,
  }) async {
    drawCalls++;
    lastBannerId = bannerId;
    lastTenPull = tenPull;
    await Future<void>.delayed(drawDelay);
    if (failDraw) {
      throw StateError('draw failed');
    }
    return GachaDrawResult(
      card: tenPull ? DemoData.cards[1] : DemoData.cards.first,
      pityCount: tenPull ? 53 : 43,
    );
  }
}
