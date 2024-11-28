import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_conversion/calculate_Page/bloc/calculate_bloc_bloc.dart';
import 'package:crypto_conversion/calculate_Page/model/trickcrypto.dart';
import 'package:crypto_conversion/extension/ShimmerText.dart';
import 'package:crypto_conversion/extension/custom_text.dart';
// import 'package:crypto_conversion/extension/gobal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  late SymbolCase _coin1Id;
  late SymbolCase _coin2Id;
  late CalculateBlocBloc _calculateBloc;
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<CalculateBlocBloc, CalculateBlocState>(
      builder: (context, state) {
        // 移除 CalculateBlocLoading 的處理
        switch (state.runtimeType) {
          case CalculateBlocLoaded:
            final data = (state as CalculateBlocLoaded);
            _coin1Id = data.symbolcase[0];
            _coin2Id = data.symbolcase[1];
            return mainView('0', '0');
          case CalculatePressed:
            final data = (state as CalculatePressed);
            return mainView(data.outputCase[0], data.outputCase[1]);
          case CalculateUpDownLoaded:
            final data = (state as CalculateUpDownLoaded);
            _coin1Id = data.symbolcase[0];
            _coin2Id = data.symbolcase[1];
            return mainView(data.outputList[0], data.outputList[1]);
          default:
            // 使用一個空的初始視圖或上一次的狀態
            return Container();
        }
      },
    ));
  }

  Widget buildButton(
      String buttonText, double buttonHeight, Color buttonColor) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 0.1),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.1 * 1.12,
          color: buttonColor,
          child: TextButton(
            onPressed: () => _calculateBloc.add(PressButton(buttonText)),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 28.0, color: Colors.white),
            ),
          ),
        ));
  }

  TableRow buildButtonRow(List<String> buttonRow, Color color) {
    return TableRow(
      children: buttonRow.map((buttonLabel) {
        return buildButton(buttonLabel, 1, color);
      }).toList(),
    );
  }

  Widget buildIconButton(
      String buttonText, double buttonHeight, Color buttonColor) {
    return Material(
      color: buttonColor,
      child: InkWell(
        onTap: () {
          _calculateBloc.add(UpdownCoin());
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0.1),
          ),
          height: MediaQuery.of(context).size.height * 0.1 * 1.12,
          child: const Center(
            child: Icon(
              Icons.unfold_less_sharp,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }

  Widget buttonTable(double width, List<List<String>> buttonRows, Color color) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * width,
      child: Table(
        children: buttonRows.map((buttonRow) {
          return buildButtonRow(buttonRow, color);
        }).toList(),
      ),
    );
  }

  Widget calculateView() {
    return Container(
      // color: Colors.pink,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * .75,
            child: Table(
              children: [
                TableRow(children: [
                  buildButton("C", 1, Colors.black54),
                  buildButton("⌫", 1, Colors.black54),
                  buildIconButton("÷", 1, Colors.black54),
                ]),
                TableRow(children: [
                  buildButton("7", 1, Colors.grey),
                  buildButton("8", 1, Colors.grey),
                  buildButton("9", 1, Colors.grey),
                ]),
                TableRow(children: [
                  buildButton("4", 1, Colors.grey),
                  buildButton("5", 1, Colors.grey),
                  buildButton("6", 1, Colors.grey),
                ]),
                TableRow(children: [
                  buildButton("1", 1, Colors.grey),
                  buildButton("2", 1, Colors.grey),
                  buildButton("3", 1, Colors.grey),
                ]),
                TableRow(children: [
                  buildButton("0", 1, Colors.grey),
                  buildButton(".", 1, Colors.grey),
                  buildButton("00", 1, Colors.grey),
                ]),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * .25,
            child: Table(
              children: [
                TableRow(children: [
                  buildButton("÷", 1, Colors.orange),
                ]),
                TableRow(children: [
                  buildButton("×", 1, Colors.orange),
                ]),
                TableRow(children: [
                  buildButton("-", 1, Colors.orange),
                ]),
                TableRow(children: [
                  buildButton("+", 1, Colors.orange),
                ]),
                TableRow(children: [
                  buildButton("=", 1, Colors.orange),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget coinSection(
      bool item, SymbolCase coin, String output, VoidCallback onTap) {
    return Flexible(
        flex: 4,
        child: GestureDetector(
            onTap: onTap,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                    flex: 2,
                    child: Flex(
                      direction: Axis.vertical,
                      children: [
                        Flexible(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.blueGrey[700],
                            alignment: Alignment.centerLeft,
                            child: cryptoImage(coin.symbolData.image),
                          ),
                        ),
                        Flexible(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.only(left: 5),
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.blueGrey[700],
                              alignment: Alignment.topCenter,
                              child:
                                  CustomText(textContent: coin.symbolData.coin),
                            ))
                      ],
                    )),
                Flexible(
                    flex: 8,
                    child: Container(
                      padding: const EdgeInsets.only(right: 10),
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.blueGrey[700],
                      alignment: Alignment.centerRight,
                      child: CustomText(
                        textContent: output,
                        textColor: Colors.white,
                        fontSize: 24,
                      ),
                    ))
              ],
            )));
  }

  Widget cryptoImage(String imageUrl) {
    return ClipOval(
      child: SizedBox(
        width: 150,
        height: 150,
        child: CachedNetworkImage(
          width: 150,
          height: 150,
          placeholder: (context, url) => const ShimmerBox(),
          imageUrl: imageUrl,
          errorWidget: (context, url, error) =>
              Image.asset('assets/cryptoIcon.png'),
        ),
      ),
    );
  }

  String fetchData(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      String formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour}:${date.minute}";
      return formattedDate;
    } catch (e) {
      // 如果解析日期時發生錯誤，返回當前時間
      DateTime now = DateTime.now();
      String currentDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour}:${now.minute}";
      return currentDate;
    }
  }

  String formatCurrencyRate() {
    double rate = _coin1Id.price / _coin2Id.price;

    // Handle extremely small rates using scientific notation
    if (rate < 0.0001) {
      // Use scientific notation conversion from previous method
      String scientificNotation = rate.toStringAsExponential(6);
      String formattedRate = _formatScientificToDecimal(scientificNotation);
      return '1 ${_coin1Id.symbolData.coin.toUpperCase()} = $formattedRate ${_coin2Id.symbolData.coin.toUpperCase()}';
    }

    // Check for consecutive zeros
    String rateString = rate.toStringAsFixed(8);
    RegExp zeroRegex = RegExp(r'\.?0{3,}');

    if (zeroRegex.hasMatch(rateString)) {
      // Similar to small rate handling
      String scientificNotation = rate.toStringAsExponential(6);
      String formattedRate = _formatScientificToDecimal(scientificNotation);
      return '1 ${_coin1Id.symbolData.coin.toUpperCase()} = $formattedRate ${_coin2Id.symbolData.coin.toUpperCase()}';
    }

    // Find appropriate decimal places for display
    if (rateString.contains('.')) {
      RegExp nonZeroRegex = RegExp(r'\.([1-9][0-9]*)');
      var match = nonZeroRegex.firstMatch(rateString);

      if (match != null) {
        int decimalPlaces = match.group(1)!.length;
        // Limit to max 4 decimal places for readability
        decimalPlaces = decimalPlaces > 2 ? 2 : decimalPlaces;
        return '1 ${_coin1Id.symbolData.coin.toUpperCase()} = ${rate.toStringAsFixed(decimalPlaces)} ${_coin2Id.symbolData.coin.toUpperCase()}';
      }
    }

    // Default to 4 decimal places
    return '1 ${_coin1Id.symbolData.coin.toUpperCase()} = ${rate.toStringAsFixed(2)} ${_coin2Id.symbolData.coin.toUpperCase()}';
  }

  @override
  initState() {
    super.initState();
    _calculateBloc = BlocProvider.of<CalculateBlocBloc>(context);
    _calculateBloc.add(FetchInitData());
  }

  Widget loadingMainView() {
    return Flex(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      direction: Axis.vertical,
      children: [
        Flexible(
          flex: 10,
          child: Shimmer.fromColors(
            baseColor: Colors.blueGrey, // 更改此颜色为你想要的颜色
            highlightColor: Colors.grey, // 更改此颜色为你想要的颜色
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
            ),
          ),
        ),
        Flexible(flex: 14, child: calculateView()),
        Flexible(
          flex: 2,
          child: Shimmer.fromColors(
            baseColor: Colors.blueGrey, // 更改此颜色为你想要的颜色
            highlightColor: Colors.grey, // 更改此颜色为你想要的颜色
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget mainView(String output1, String output2) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 63, 58, 58).withOpacity(0.9),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  _buildCoinSection(true, _coin1Id, output1),
                  _buildCoinSection(false, _coin2Id, output2),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: calculateView(),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () => _calculateBloc.add(FetchInitData()),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('更新匯率', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 47, 54, 59),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fetchData(_coin1Id.changePercent),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  //避免文字過長用fitbox
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatCurrencyRate(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinSection(bool isFirstCoin, SymbolCase coinId, String output) {
    return GestureDetector(
      onTap: () =>
          _calculateBloc.add(PressChangeCoin(context, isFirstCoin ? '0' : '1')),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 63, 58, 58).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52, // 可以調整大小
              height: 52,
              decoration: BoxDecoration(
                color: coinId.symbolData.iscrypto
                    ? Colors.white
                    : Colors.white.withAlpha(1),
                shape: coinId.symbolData.iscrypto
                    ? BoxShape.circle
                    : BoxShape.rectangle, // 保持矩形形狀
                image: DecorationImage(
                  image: NetworkImage(coinId.symbolData.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coinId.symbolData.name.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      output,
                      style: const TextStyle(
                        fontSize: 21,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // Reuse the scientific notation conversion method from previous example
  String _formatScientificToDecimal(String scientificNotation) {
    RegExp exp = RegExp(r'([\d.]+)e([+-])(\d+)');
    Match? match = exp.firstMatch(scientificNotation);

    if (match == null) return "0";

    String baseNumber = match.group(1)!;
    String sign = match.group(2)!;
    int exponent = int.parse(match.group(3)!);

    baseNumber = baseNumber.replaceAll('.', '');

    int leadingZeros = sign == '-' ? exponent - 1 : 0;

    String result = '0.${'0' * leadingZeros}$baseNumber';

    return result;
  }
}
