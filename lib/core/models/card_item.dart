import 'package:flutter/material.dart';

enum CardRarity { common, rare, epic, legendary }

extension CardRarityX on CardRarity {
  String get label {
    return switch (this) {
      CardRarity.common => 'N',
      CardRarity.rare => 'R',
      CardRarity.epic => 'SR',
      CardRarity.legendary => 'SSR',
    };
  }

  Color get color {
    return switch (this) {
      CardRarity.common => const Color(0xFF93A0BD),
      CardRarity.rare => const Color(0xFF66C7FF),
      CardRarity.epic => const Color(0xFFB37CFF),
      CardRarity.legendary => const Color(0xFFFFD36E),
    };
  }
}

class CardItem {
  const CardItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.rarity,
    required this.symbol,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    this.isNew = false,
  });

  final String id;
  final String name;
  final String subtitle;
  final CardRarity rarity;
  final String symbol;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final bool isNew;

  factory CardItem.fromJson(Map<String, dynamic> json) {
    return CardItem(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? '未命名卡片',
      subtitle: json['subtitle'] as String? ?? '未知档案',
      rarity: _rarityFromJson(json['rarity'] as String?),
      symbol: json['symbol'] as String? ?? 'U-00',
      primaryColor: _colorFromHex(json['primaryColor'] as String?),
      secondaryColor: _colorFromHex(
        json['secondaryColor'] as String?,
        fallback: const Color(0xFF4A4E82),
      ),
      icon: _iconFromJson(json['icon'] as String?),
      isNew: json['isNew'] as bool? ?? false,
    );
  }
}

CardRarity _rarityFromJson(String? value) {
  return CardRarity.values.firstWhere(
    (rarity) => rarity.name == value,
    orElse: () => CardRarity.common,
  );
}

Color _colorFromHex(String? value, {Color fallback = const Color(0xFF6DE8FF)}) {
  if (value == null || value.isEmpty) {
    return fallback;
  }
  final normalized = value.replaceFirst('#', '');
  final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}

IconData _iconFromJson(String? value) {
  return switch (value) {
    'nightlight_round' => Icons.nightlight_round,
    'bolt' => Icons.bolt,
    'water_drop' => Icons.water_drop,
    'public' => Icons.public,
    'graphic_eq' => Icons.graphic_eq,
    _ => Icons.auto_awesome,
  };
}
