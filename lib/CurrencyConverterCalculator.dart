import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyConverterCalculator extends StatefulWidget {
  const CurrencyConverterCalculator({super.key});

  @override
  _CurrencyConverterCalculatorState createState() =>
      _CurrencyConverterCalculatorState();
}

class _CurrencyConverterCalculatorState
    extends State<CurrencyConverterCalculator> {
  String _input = '0';
  final String _fromCurrency = 'USD';
  final String _toCurrency = 'TWD';
  final double _exchangeRate = 32.2; // 假設的匯率

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildCurrencyRow(_fromCurrency, _input),
            _buildCurrencyRow(_toCurrency,
                (double.parse(_input) * _exchangeRate).toStringAsFixed(2)),
            const Divider(color: Colors.grey, height: 1),
            Expanded(child: _buildKeypad()),
            _buildBottomRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomRow() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy/MM/dd a hh:mm').format(now);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.green),
            onPressed: () {},
          ),
          Text(formattedDate, style: const TextStyle(color: Colors.green)),
          Text('1 USD = $_exchangeRate TWD',
              style: const TextStyle(color: Colors.grey)),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, ButtonStyle style) {
    return ElevatedButton(
      style: style,
      child: Text(label, style: const TextStyle(fontSize: 24)),
      onPressed: () => _onKeyPress(label),
    );
  }

  Widget _buildCurrencyFlag(String currency) {
    final Map<String, Color> flagColors = {
      'USD': Colors.blue,
      'TWD': Colors.red,
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: flagColors[currency],
      ),
      child: Center(
        child: Text(
          currency == 'USD' ? '🇺🇸' : '🇹🇼',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildCurrencyRow(String currency, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildCurrencyFlag(currency),
          const SizedBox(width: 8),
          Text(currency,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          const Spacer(),
          Text(amount,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    final buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
    );

    return GridView.count(
      crossAxisCount: 4,
      childAspectRatio: 1.5,
      children: [
        _buildButton('C', buttonStyle),
        _buildButton('←', buttonStyle),
        _buildButton('↑↓', buttonStyle),
        _buildButton(
            '÷', ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
        ...'789456123.0%'
            .split('')
            .map((key) => _buildButton(key, buttonStyle)),
        _buildButton(
            '×', ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
        _buildButton(
            '-', ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
        _buildButton(
            '+', ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
        _buildButton(
            '=', ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
      ],
    );
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == 'C') {
        _input = '0';
      } else if (key == '←') {
        _input =
            _input.length > 1 ? _input.substring(0, _input.length - 1) : '0';
      } else if (key == '↑↓') {
        // 實現貨幣切換邏輯
      } else if ('0123456789.'.contains(key)) {
        _input = _input == '0' ? key : _input + key;
      }
      // 這裡可以添加更多按鍵處理邏輯
    });
  }
}
