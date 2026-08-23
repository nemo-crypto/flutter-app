import 'package:flutter/material.dart';

import '../../core/models/card_item.dart';
import 'rarity_badge.dart';

class CardArt extends StatelessWidget {
  const CardArt({
    super.key,
    required this.card,
    this.height = 188,
    this.showName = true,
  });

  final CardItem card;
  final double height;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = height.isFinite ? height : constraints.maxHeight;
        return Container(
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                card.primaryColor.withValues(alpha: 0.92),
                card.secondaryColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: card.primaryColor.withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned(
                  right: -32,
                  top: -48,
                  child: _Orb(
                    size: cardHeight * 0.78,
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                Positioned(
                  left: -46,
                  bottom: -54,
                  child: _Orb(
                    size: cardHeight * 0.66,
                    color: Colors.black.withValues(alpha: 0.14),
                  ),
                ),
                Positioned(
                  right: 14,
                  top: 14,
                  child: Text(
                    card.symbol,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.64),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 18,
                  child: RarityBadge(rarity: card.rarity),
                ),
                Center(
                  child: Icon(
                    card.icon,
                    size: cardHeight * 0.34,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                if (showName)
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          card.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
