import '../domain/gacha_models.dart';

abstract interface class GachaRepository {
  Future<GachaCatalog> loadCatalog();

  Future<GachaDrawResult> draw({
    required String bannerId,
    required bool tenPull,
  });
}
