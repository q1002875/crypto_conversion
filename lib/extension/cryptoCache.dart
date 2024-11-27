import 'package:crypto_conversion/calculate_Page/model/trickcrypto.dart';

class CryptoCache {
  static final Map<String, List<Trickcrypto>> _cache = {};

  static void cacheData(String key, List<Trickcrypto> data) {
    _cache[key] = data;
  }

  static void clearCache() {
    _cache.clear();
  }

  static List<Trickcrypto>? getCachedData(String key) {
    return _cache[key];
  }
}
