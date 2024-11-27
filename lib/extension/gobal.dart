import 'package:flutter/material.dart';

late double screenHeight;
late double screenWidth;
String formatOutputNumber(String output) {
  // 先將字串轉為 double
  double? number = double.tryParse(output);
  if (number == null) return output;

  // 如果是 0，直接返回 "0"
  if (number == 0) return "0";

  // 分離整數和小數部分
  List<String> parts = number.toString().split('.');
  String integerPart = parts[0];
  // 只有當小數部分不為 0 時才添加小數部分
  String decimalPart =
      parts.length > 1 && parts[1] != '0' ? '.${parts[1]}' : '';

  // 處理整數部分，每三位加一個逗號
  final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String result = integerPart.replaceAllMapped(reg, (Match m) => '${m[1]},');

  // 組合整數和小數部分
  return result + decimalPart;
}

void setScreenHeight(BuildContext context) {
  screenHeight = MediaQuery.of(context).size.height;
}

void setscreenWidth(BuildContext context) {
  screenWidth = MediaQuery.of(context).size.width;
}
