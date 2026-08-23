import 'package:flutter/material.dart';

import '../../core/models/card_item.dart';

class RarityBadge extends StatelessWidget {
  const RarityBadge({super.key, required this.rarity, this.compact = false});

  final CardRarity rarity;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: rarity.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: rarity.color.withValues(alpha: 0.46)),
      ),
      child: Text(
        rarity.label,
        style: TextStyle(
          color: rarity.color,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
