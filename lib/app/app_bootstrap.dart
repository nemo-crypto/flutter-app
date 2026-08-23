import '../core/config/app_config.dart';
import '../core/network/http_api_client.dart';
import '../features/gacha/data/demo_gacha_repository.dart';
import '../features/gacha/data/gacha_repository.dart';
import '../features/gacha/data/remote_gacha_repository.dart';

abstract final class AppBootstrap {
  static GachaRepository createGachaRepository() {
    final baseUrl = AppConfig.apiBaseUrl.trim();
    if (AppConfig.useMockApi || baseUrl.isEmpty) {
      return DemoGachaRepository();
    }

    return RemoteGachaRepository(HttpApiClient(baseUri: Uri.parse(baseUrl)));
  }
}
