import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:crypto_conversion/calculate_Page/crypto_search_page.dart';
import 'package:crypto_conversion/calculate_Page/model/trickcrypto.dart';
import 'package:crypto_conversion/extension/SharedPreferencesHelper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

part 'calculate_bloc_event.dart';
part 'calculate_bloc_state.dart';

class CalculateBlocBloc extends Bloc<CalculateBlocEvent, CalculateBlocState> {
  String _output = "0";
  double _num1 = 0.0;
  double _num2 = 0.0;
  String _output2 = "0";

  // 添加緩存
  SymbolCase? _cachedCoin1Id;
  SymbolCase? _cachedCoin2Id;
  List<String>? _cachedOutput;

  late SymbolCase _coin1Id;
  late SymbolCase _coin2Id;
  Operation _operator = Operation.none;
  bool _newNumber = true;
  CalculateBlocBloc() : super(CalculateBlocInitial()) {
    on<CalculateBlocEvent>((event, emit) async {
      if (event is FetchInitData) {
        // 如果有緩存數據，先發送緩存的狀態
        if (_cachedCoin1Id != null && _cachedCoin2Id != null) {
          emit(CalculateBlocLoaded(
              symbolcase: [_cachedCoin1Id!, _cachedCoin2Id!]));
        }

        try {
          List<SymbolCase> symbolList = await checkSaveCoin();
          _coin1Id = symbolList[0];
          _coin2Id = symbolList[1];

          // 更新緩存
          _cachedCoin1Id = _coin1Id;
          _cachedCoin2Id = _coin2Id;

          emit(CalculateBlocLoaded(symbolcase: symbolList));
        } catch (_) {
          // 如果有緩存，在錯誤時使用緩存數據
          if (_cachedCoin1Id != null && _cachedCoin2Id != null) {
            emit(CalculateBlocLoaded(
                symbolcase: [_cachedCoin1Id!, _cachedCoin2Id!]));
          } else {
            emit(CalculateBlocError());
          }
        }
      } else if (event is PressButton) {
        if (_cachedOutput != null) {
          emit(CalculatePressed(outputCase: _cachedOutput!));
        }

        _buttonPressed(event.input);
        final List<String> output = [_output, _output2];

        // 更新緩存
        _cachedOutput = output;

        emit(CalculatePressed(outputCase: output));
      } else if (event is PressChangeCoin) {
        // 如果有緩存，先發送緩存狀態
        if (_cachedCoin1Id != null && _cachedCoin2Id != null) {
          emit(CalculateBlocLoaded(
              symbolcase: [_cachedCoin1Id!, _cachedCoin2Id!]));
        }

        try {
          switch (event.item) {
            case '0':
            case '1':
              final isFirstCase = event.item == '0';
              Trickcrypto data = await Navigator.push(
                event.context,
                MaterialPageRoute(
                    builder: (context) => const CryptoSearchPage('')),
              );

              if (data.id.isEmpty || data.id == '') {
                data = isFirstCase ? _coin1Id.symbolData : _coin2Id.symbolData;
              }

              final key = isFirstCase ? 'coinId1' : 'coinId2';
              await SharedPreferencesHelper.setTrickcrypto(key, data);

              final result = await fetchMarketData(data);
              if (isFirstCase) {
                _coin1Id = result!;
                _cachedCoin1Id = result;
              } else {
                _coin2Id = result!;
                _cachedCoin2Id = result;
              }
              break;
          }

          emit(CalculateBlocLoaded(symbolcase: [_coin1Id, _coin2Id]));
        } catch (e) {
          // 發生錯誤時使用緩存
          if (_cachedCoin1Id != null && _cachedCoin2Id != null) {
            emit(CalculateBlocLoaded(
                symbolcase: [_cachedCoin1Id!, _cachedCoin2Id!]));
          }
        }
      } else if (event is UpdownCoin) {
        // 使用當前狀態作為緩存
        final tempCoin1 = _coin1Id;
        final tempCoin2 = _coin2Id;

        _coin1Id = tempCoin2;
        _coin2Id = tempCoin1;

        // 更新緩存
        _cachedCoin1Id = _coin1Id;
        _cachedCoin2Id = _coin2Id;

        SharedPreferencesHelper.setTrickcrypto('coinId1', _coin1Id.symbolData);
        SharedPreferencesHelper.setTrickcrypto('coinId2', _coin2Id.symbolData);

        _output = "0";
        _output2 = "0";
        _num1 = 0.0;
        _num2 = 0.0;
        emit(CalculateUpDownLoaded(
            symbolcase: [_coin1Id, _coin2Id], outputList: [_output, _output2]));
      }
    });
  }

  Future<List<SymbolCase>> checkSaveCoin() async {
    final coin1Id = await getCoinData('coinId1', 'bitcoin');
    final coin2Id = await getCoinData('coinId2', 'ethereum');
    return [coin1Id, coin2Id];
  }

  Future<SymbolCase?> fetchMarketData(Trickcrypto trick) async {
    if (trick.iscrypto) {
      String trickId = trick.id;
      String url =
          'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=$trickId&order=market_cap_desc&page=1&sparkline=false&locale=en';
      try {
        // 发送 GET 请求
        var response = await http.get(Uri.parse(url));

        // 检查响应状态码
        if (response.statusCode == 200) {
          // 解析响应数据
          return parseResponseData(jsonDecode(response.body));
        } else {
          debugPrint('Request failed with status: ${response.statusCode}');
          return null;
        }
      } catch (error) {
        debugPrint('Error occurred: $error');
        return null;
      }
    } else {
      String trickId = trick.id;
      String url = 'https://api.exchangerate-api.com/v4/latest/$trickId';
      try {
        // 发送 GET 请求
        var response = await http.get(Uri.parse(url));

        // 检查响应状态码
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          final usdRate = parseResponseUSDData(jsonData);
          print('1 TWD = $usdRate USD');

          return SymbolCase(trick, usdRate, "", usdRate);
        } else {
          debugPrint('Request failed with status: ${response.statusCode}');
          return null;
        }
      } catch (error) {
        debugPrint('Error occurred: $error');
        return null;
      }
    }
  }

  Future<SymbolCase> getCoinData(String coinId, String defaultCoin) async {
    Trickcrypto? coin = await SharedPreferencesHelper.getTrickcrypto(coinId);

    // 如果 coin 為 null，則創建一個新的 Trickcrypto 物件
    coin ??=
        Trickcrypto(defaultCoin, defaultCoin, 'Unknown Name', 'Unknown Image');

    // 確保 coin 不為 null 後進行數據請求
    final coinData = await fetchMarketData(coin);

    // 檢查 fetchMarketData 返回的 coinData
    if (coinData != null) {
      return coinData;
    } else {
      throw Exception('Failed to fetch coin data');
    }
  }

  SymbolCase? parseResponseData(List<dynamic> data) {
    if (data.isNotEmpty) {
      final item = data[0];
      final id = item['id'];
      final symbol = item['symbol'];
      final name = item['name'];
      final image = item['image'];
      final currentPrice = item['current_price'];
      final changePrice = item['price_change_24h']; //變化的美元
      final changePercent = item["last_updated"]; //變化的百分比
      final trick = Trickcrypto(symbol, id, name, image);

      return SymbolCase(trick, currentPrice, changePercent, changePrice);
    } else {
      debugPrint('No data received');
      return null;
    }
  }

  dynamic parseResponseUSDData(Map<String, dynamic> jsonData) {
    // 提取 "rates" 字段中的美元汇率
    return jsonData['rates']['USD'];
  }

  void _buttonPressed(String buttonText) {
    switch (buttonText) {
      case "⌫":
        if (_output.length > 1) {
          _output = _output.substring(0, _output.length - 1);
          _updateSecondaryDisplay();
        } else {
          _output = "0";
          _output2 = "0";
        }
        break;

      case "C":
        _clearCalculator();
        break;

      case "+":
      case "-":
      case "×":
      case "÷":
        _handleOperator(buttonText);
        break;

      case ".":
        _handleDecimalPoint();
        break;

      case "=":
        _calculateResult();
        break;

      default:
        _handleNumber(buttonText);
        break;
    }
  }

  void _calculateResult() {
    try {
      if (_operator == Operation.none) return;

      _num2 = double.parse(_output);
      double result = 0.0;

      switch (_operator) {
        case Operation.add:
          result = _num1 + _num2;
          break;
        case Operation.subtract:
          result = _num1 - _num2;
          break;
        case Operation.multiply:
          result = _num1 * _num2;
          break;
        case Operation.divide:
          if (_num2 == 0) {
            _clearCalculator();
            return;
          }
          result = _num1 / _num2;
          break;
        case Operation.none:
          return;
      }

      // 格式化結果，去除不必要的小數零
      _output = _formatNumber(result);
      _updateSecondaryDisplay();

      // 重置計算器狀態
      _operator = Operation.none;
      _num1 = result;
      _num2 = 0.0;
      _newNumber = true;
    } catch (e) {
      debugPrint('Error calculating result: $e');
      _clearCalculator();
    }
  }

  void _clearCalculator() {
    _output = "0";
    _output2 = "0";
    _num1 = 0.0;
    _num2 = 0.0;
    _operator = Operation.none;
    _newNumber = true;
  }

  String _formatNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    // 移除尾部的零，但保留必要的小數位
    String result = number.toString();
    while (result.contains('.') &&
        (result.endsWith('0') || result.endsWith('.'))) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  // 辅助方法：将科学计数法转换为精确的小数形式
  String _formatScientificToDecimal(String scientificNotation) {
    // 解析科学计数法
    RegExp exp = RegExp(r'([\d.]+)e([+-])(\d+)');
    Match? match = exp.firstMatch(scientificNotation);

    if (match == null) return "0";

    String baseNumber = match.group(1)!;
    String sign = match.group(2)!;
    int exponent = int.parse(match.group(3)!);

    // 移除基数中的小数点
    baseNumber = baseNumber.replaceAll('.', '');

    // 计算需要的前导零数量
    int leadingZeros = sign == '-' ? exponent - 1 : 0;

    // 构建最终的小数表示
    String result = '0.${'0' * leadingZeros}$baseNumber';

    return result;
  }

  Operation _getOperation(String op) {
    switch (op) {
      case "+":
        return Operation.add;
      case "-":
        return Operation.subtract;
      case "×":
        return Operation.multiply;
      case "÷":
        return Operation.divide;
      default:
        return Operation.none;
    }
  }

  void _handleDecimalPoint() {
    if (_newNumber) {
      _output = "0.";
      _newNumber = false;
    } else if (!_output.contains(".")) {
      _output += ".";
    }
    _updateSecondaryDisplay();
  }

  void _handleNumber(String number) {
    if (_newNumber) {
      _output = number;
      _newNumber = false;
    } else {
      // 處理前導零的情況
      if (_output == "0" && number != "0" && !_output.contains(".")) {
        _output = number;
      } else if (_output != "0" || _output.contains(".") || number != "0") {
        _output += number;
      }
    }
    _updateSecondaryDisplay();
  }

  void _handleOperator(String op) {
    try {
      if (_operator != Operation.none) {
        _calculateResult(); // 如果已有運算符，先計算之前的結果
      }
      _num1 = double.parse(_output);
      _operator = _getOperation(op);
      _newNumber = true;
    } catch (e) {
      debugPrint('Error handling operator: $e');
      _clearCalculator();
    }
  }

  void _updateSecondaryDisplay() {
    try {
      double currentValue = double.parse(_output);
      double conversionRate = _coin1Id.price / _coin2Id.price;
      double convertedValue = currentValue * conversionRate;

      // 处理零值情况
      if (convertedValue == 0) {
        _output2 = "0";
        return;
      }

      // 对于非常小的数值
      if (convertedValue < 0.01) {
        // 使用科学计数法转换
        String scientificNotation = convertedValue.toStringAsExponential(6);
        // 如果使用科学计数法
        if (convertedValue != 0) {
          // 将科学计数法转换为小数形式
          _output2 = _formatScientificToDecimal(scientificNotation);
          return;
        }
      }

      // 对于一般数值
      _output2 = convertedValue.toStringAsFixed(2);
    } catch (e) {
      debugPrint('Error updating secondary display: $e');
      _output2 = "0";
    }
  }
}

enum Operation { add, subtract, multiply, divide, none }
