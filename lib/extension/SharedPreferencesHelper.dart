import '../calculate_Page/model/trickcrypto.dart';
import 'common.dart';

class SharedPreferencesHelper {
  static Future<String> getString(String key,
      {String defaultValue = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }

  // 獲取 Trickcrypto 物件
  static Future<Trickcrypto?> getTrickcrypto(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(key);
    if (jsonString != null) {
      Map<String, dynamic> jsonData = jsonDecode(jsonString); // 反序列化 JSON
      return Trickcrypto.fromJson(jsonData); // 轉換為 Trickcrypto 物件
    }
    return null;
  }

  static Future<bool> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static Future<bool> setTrickcrypto(String key, Trickcrypto crypto) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(crypto.toJson()); // 序列化為 JSON 字符串
    return prefs.setString(key, jsonString);
  }
}
