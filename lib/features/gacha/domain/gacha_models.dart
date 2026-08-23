import '../../../core/models/card_item.dart';

class GachaBanner {
  const GachaBanner({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;

  factory GachaBanner.fromJson(Map<String, dynamic> json) {
    return GachaBanner(
      id: json['id'] as String? ?? 'default',
      title: json['title'] as String? ?? '未知卡池',
      subtitle: json['subtitle'] as String? ?? '概率提升',
    );
  }
}

class GachaCatalog {
  const GachaCatalog({required this.banners, required this.cards});

  final List<GachaBanner> banners;
  final List<CardItem> cards;

  factory GachaCatalog.fromJson(Map<String, dynamic> json) {
    final banners = _asMapList(json['banners'])
        .map(GachaBanner.fromJson)
        .toList(growable: false);
    final cards = _asMapList(json['cards'])
        .map(CardItem.fromJson)
        .toList(growable: false);
    return GachaCatalog(banners: banners, cards: cards);
  }
}

class GachaDrawResult {
  const GachaDrawResult({required this.card, required this.pityCount});

  final CardItem card;
  final int pityCount;

  factory GachaDrawResult.fromJson(Map<String, dynamic> json) {
    final cardJson = json['card'];
    if (cardJson is! Map<String, dynamic>) {
      throw const FormatException('抽卡结果缺少 card 字段');
    }
    return GachaDrawResult(
      card: CardItem.fromJson(cardJson),
      pityCount: json['pityCount'] as int? ?? 0,
    );
  }
}

List<Map<String, dynamic>> _asMapList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}
