import 'package:flutter/material.dart';

import '../../../core/models/card_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/card_art.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../gacha/application/gacha_controller.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key, required this.controller});

  final GachaController controller;

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  CardRarity? _selectedRarity;

  List<CardItem> _filteredCards(List<CardItem> cards) {
    if (_selectedRarity == null) {
      return cards;
    }
    return cards.where((card) => card.rarity == _selectedRarity).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final allCards = widget.controller.catalog?.cards ?? const <CardItem>[];
        if (allCards.isEmpty) {
          return _CollectionState(
            isLoading: widget.controller.isLoading,
            errorMessage: widget.controller.errorMessage,
            onRetry: widget.controller.retry,
          );
        }
        final cards = _filteredCards(allCards);
        return CustomScrollView(
          key: const Key('page-collection'),
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '星辉图鉴',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '收集每一段被记录的宇宙回声',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${allCards.length}/128',
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _FilterBar(
                    selectedRarity: _selectedRarity,
                    onChanged: (rarity) =>
                        setState(() => _selectedRarity = rarity),
                  ),
                  const SizedBox(height: 18),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 13,
                  crossAxisSpacing: 13,
                  childAspectRatio: 0.73,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return _CollectionCard(card: cards[index]);
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      },
    );
  }
}

class _CollectionState extends StatelessWidget {
  const _CollectionState({
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final message = isLoading ? '正在同步图鉴数据' : errorMessage ?? '暂无图鉴数据';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLoading
                    ? Icons.sync_rounded
                    : Icons.collections_bookmark_outlined,
                color: isLoading ? AppColors.cyan : AppColors.pink,
                size: 32,
              ),
              const SizedBox(height: 14),
              if (isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.cyan,
                    strokeWidth: 2,
                  ),
                ),
              if (isLoading) const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!isLoading) ...[
                const SizedBox(height: 14),
                OutlinedButton(
                  key: const Key('collection-retry'),
                  onPressed: onRetry,
                  child: const Text('重新加载'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selectedRarity, required this.onChanged});

  final CardRarity? selectedRarity;
  final ValueChanged<CardRarity?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            chipKey: const Key('rarity-filter-all'),
            label: '全部',
            selected: selectedRarity == null,
            color: AppColors.cyan,
            onTap: () => onChanged(null),
          ),
          for (final rarity in CardRarity.values) ...[
            const SizedBox(width: 8),
            _FilterChip(
              chipKey: ValueKey('rarity-filter-${rarity.label}'),
              label: rarity.label,
              selected: selectedRarity == rarity,
              color: rarity.color,
              onTap: () => onChanged(rarity),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.chipKey,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final Key chipKey;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: chipKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : AppColors.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? color : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.card});

  final CardItem card;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(8),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CardArt(
              card: card,
              height: double.infinity,
              showName: false,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    card.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  card.rarity.label,
                  style: TextStyle(
                    color: card.rarity.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              card.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(height: 7),
        ],
      ),
    );
  }
}
