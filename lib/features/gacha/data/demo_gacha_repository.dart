import '../../../core/data/demo_data.dart';
import '../domain/gacha_models.dart';
import 'gacha_repository.dart';

class DemoGachaRepository implements GachaRepository {
  var _drawIndex = 0;
  var _pityCount = 42;

  @override
  Future<GachaCatalog> loadCatalog() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
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
    await Future<void>.delayed(const Duration(milliseconds: 280));
    final offset = bannerId == 'lunar-archive' ? 2 : 0;
    final card =
        DemoData.cards[(_drawIndex++ + offset) % DemoData.cards.length];
    _pityCount += tenPull ? 10 : 1;
    return GachaDrawResult(card: card, pityCount: _pityCount);
  }
}
