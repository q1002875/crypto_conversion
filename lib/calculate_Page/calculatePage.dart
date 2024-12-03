import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_conversion/calculate_Page/bloc/calculate_bloc_bloc.dart';
import 'package:crypto_conversion/calculate_Page/model/trickcrypto.dart';
import 'package:crypto_conversion/extension/ShimmerText.dart';
import 'package:crypto_conversion/extension/common.dart';
import 'package:crypto_conversion/extension/custom_text.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<CalculateBlocBloc, CalculateBlocState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: _buildContent(context, state),
          );
        },
      ),
    );
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
            onPressed: () {
              // 播放內建的按鍵音效
              SystemSound.play(SystemSoundType.click);
              // 添加原有功能
              _calculateBloc.add(PressButton(buttonText));
            },
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
    const calerdercolor = Color.fromARGB(255, 54, 54, 54);
    const numbercolor = Color.fromARGB(255, 101, 101, 101);
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
                  buildButton("C", 1, calerdercolor),
                  buildButton("⌫", 1, calerdercolor),
                  buildIconButton("÷", 1, calerdercolor),
                ]),
                TableRow(children: [
                  buildButton("7", 1, numbercolor),
                  buildButton("8", 1, numbercolor),
                  buildButton("9", 1, numbercolor),
                ]),
                TableRow(children: [
                  buildButton("4", 1, numbercolor),
                  buildButton("5", 1, numbercolor),
                  buildButton("6", 1, numbercolor),
                ]),
                TableRow(children: [
                  buildButton("1", 1, numbercolor),
                  buildButton("2", 1, numbercolor),
                  buildButton("3", 1, numbercolor),
                ]),
                TableRow(children: [
                  buildButton("0", 1, numbercolor),
                  buildButton(".", 1, numbercolor),
                  buildButton("00", 1, numbercolor),
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 38, 38, 38),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                child: Column(
                  children: [
                    // 第一個幣種載入模擬
                    _buildCoinLoadingItem(),
                    const Divider(thickness: 0.1),
                    // 第二個幣種載入模擬
                    _buildCoinLoadingItem(),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: calculateView(),
            ),
            // 底部載入效果
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget mainView(String output1, String output2) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 38, 38, 38).withOpacity(1),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildCoinSection(true, _coin1Id, output1),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      color: Colors.white, // 设置白色线条
                      thickness: 0.1, // 设置线条厚度
                    ),
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF262626), // 黑灰色背景
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
            label: const Text('更新匯率',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F363B), // 深灰色按鈕背景
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
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      fetchData(_coin1Id.changePercent),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF0EC95A), // 綠色
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatCurrencyRate(),
                      style: TextStyle(
                        color: Colors.grey[400],
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

  Widget _buildCoinLoadingItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 左側圓圈
          Container(
            width: 60,
            height: 90,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          // 中間文字模擬
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 幣種名稱模擬
                Container(
                  width: 100,
                  height: 20,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                // 幣種數值模擬
                Container(
                  width: 150,
                  height: 25,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          // 右側箭頭
          Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
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
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
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

  Widget _buildContent(BuildContext context, CalculateBlocState state) {
    switch (state.runtimeType) {
      case CalculateBlocLoaded:
        final data = (state as CalculateBlocLoaded);
        _coin1Id = data.symbolcase[0];
        _coin2Id = data.symbolcase[1];
        return mainView("0", "0");
      case CalculatePressed:
        final data = (state as CalculatePressed);
        return mainView(data.outputCase[0], data.outputCase[1]);
      case CalculateUpDownLoaded:
        final data = (state as CalculateUpDownLoaded);
        _coin1Id = data.symbolcase[0];
        _coin2Id = data.symbolcase[1];
        return mainView(data.outputList[0], data.outputList[1]);
      default:
        // 使用 loadingMainView
        return loadingMainView();
    }
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
