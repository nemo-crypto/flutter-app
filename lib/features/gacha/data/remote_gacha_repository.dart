import '../../../core/network/api_client.dart';
import '../domain/gacha_models.dart';
import 'gacha_repository.dart';

class RemoteGachaRepository implements GachaRepository {
  const RemoteGachaRepository(this._client);

  final ApiClient _client;

  @override
  Future<GachaCatalog> loadCatalog() async {
    final payload = await _client.getJson('/v1/gacha/catalog');
    if (payload is! Map<String, dynamic>) {
      throw const ApiException(message: '卡池接口返回格式错误');
    }
    return GachaCatalog.fromJson(payload);
  }

  @override
  Future<GachaDrawResult> draw({
    required String bannerId,
    required bool tenPull,
  }) async {
    final payload = await _client.postJson(
      '/v1/gacha/draw',
      body: {'bannerId': bannerId, 'count': tenPull ? 10 : 1},
    );
    if (payload is! Map<String, dynamic>) {
      throw const ApiException(message: '抽卡接口返回格式错误');
    }
    return GachaDrawResult.fromJson(payload);
  }
}
