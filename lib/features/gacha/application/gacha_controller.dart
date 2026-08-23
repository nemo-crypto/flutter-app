import 'package:flutter/foundation.dart';

import '../../../core/models/card_item.dart';
import '../../../core/network/api_client.dart';
import '../data/gacha_repository.dart';
import '../domain/gacha_models.dart';

class GachaController extends ChangeNotifier {
  GachaController({required this.repository});

  final GachaRepository repository;

  GachaCatalog? _catalog;
  CardItem? _lastResult;
  var _selectedBannerIndex = 0;
  var _pullCount = 42;
  var _isLoading = false;
  var _isInitialized = false;
  String? _errorMessage;

  GachaCatalog? get catalog => _catalog;
  CardItem? get lastResult => _lastResult;
  int get selectedBannerIndex => _selectedBannerIndex;
  int get pullCount => _pullCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    _isLoading = true;
    notifyListeners();
    try {
      final catalog = await repository.loadCatalog();
      _catalog = catalog;
      _selectedBannerIndex = catalog.banners.isEmpty
          ? 0
          : _selectedBannerIndex.clamp(0, catalog.banners.length - 1).toInt();
      _lastResult = _firstFeaturedCard(catalog.cards);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = _messageForError(error, '卡池加载失败，请稍后重试');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    if (_isLoading) {
      return;
    }
    _isInitialized = false;
    await initialize();
  }

  void selectBanner(int index) {
    final banners = _catalog?.banners ?? const <GachaBanner>[];
    if (index < 0 || index >= banners.length || index == _selectedBannerIndex) {
      return;
    }
    _selectedBannerIndex = index;
    notifyListeners();
  }

  Future<void> draw({required bool tenPull}) async {
    final catalog = _catalog;
    if (_isLoading || catalog == null || catalog.banners.isEmpty) {
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await repository.draw(
        bannerId: catalog.banners[_selectedBannerIndex].id,
        tenPull: tenPull,
      );
      _lastResult = result.card;
      _pullCount = result.pityCount;
    } catch (error) {
      _errorMessage = _messageForError(error, '抽卡请求失败，请检查网络后重试');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _messageForError(Object error, String fallback) {
    if (error is ApiException && error.message.isNotEmpty) {
      return error.message;
    }
    return fallback;
  }

  CardItem? _firstFeaturedCard(List<CardItem> cards) {
    for (final card in cards) {
      if (card.rarity == CardRarity.legendary) {
        return card;
      }
    }
    return cards.isEmpty ? null : cards.first;
  }
}
