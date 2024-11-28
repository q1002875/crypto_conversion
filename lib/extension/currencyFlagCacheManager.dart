// currency_flag_cache.dart
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'currencyData.dart';

class CurrencyFlagCache {
  static final CurrencyFlagCache _instance = CurrencyFlagCache._internal();
  // 存儲已緩存的貨幣旗幟文件路徑
  Map<String, String> cachedFlagPaths = {};
  factory CurrencyFlagCache() => _instance;

  CurrencyFlagCache._internal();

  // 根據貨幣名稱獲取本地圖片路徑
  String? getLocalFlagPath(String currencyName) {
    return cachedFlagPaths[currencyName];
  }

  // 預加載所有貨幣旗幟
  Future<void> preloadCurrencyFlags() async {
    try {
      // 獲取本地存儲目錄
      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/currency_flags';

      // 確保目錄存在
      await Directory(localPath).create(recursive: true);

      // 並行下載
      await Future.wait(CurrencyData.currencies.map((currency) async {
        final fileName = '${currency['name'].toLowerCase()}_flag.png';
        final localFile = File('$localPath/$fileName');

        // 如果文件已存在，直接添加到緩存
        if (await localFile.exists()) {
          cachedFlagPaths[currency['name']] = localFile.path;
          return;
        }

        // 下載圖片
        final response = await http.get(Uri.parse(currency['image']));

        if (response.statusCode == 200) {
          // 保存到本地
          await localFile.writeAsBytes(response.bodyBytes);
          cachedFlagPaths[currency['name']] = localFile.path;
        }
      }));

      print('Currency flags preloaded successfully');
    } catch (e) {
      print('Error preloading currency flags: $e');
    }
  }
}
