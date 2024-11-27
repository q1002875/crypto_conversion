import 'package:crypto_conversion/calculate_Page/bloc/calculate_bloc_bloc.dart';
import 'package:crypto_conversion/calculate_Page/calculatePage.dart';
import 'package:crypto_conversion/extension/common.dart';

import 'extension/cryptoCache.dart';

void main() {
  CryptoCache.clearCache();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => CalculateBlocBloc(),
        child: const CalculatorPage(),
      ),
    );
  }
}
