import 'package:crypto_conversion/calculate_Page/bloc/calculate_bloc_bloc.dart';
import 'package:crypto_conversion/calculate_Page/calculatePage.dart';
import 'package:crypto_conversion/extension/common.dart';
import 'package:crypto_conversion/extension/currencyFlagCacheManager.dart';

import 'extension/cryptoCache.dart';

Future<void> main() async {
  CryptoCache.clearCache();

  final flagCache = CurrencyFlagCache();
  await flagCache.preloadCurrencyFlags();
  // await Future.delayed(const Duration(seconds: 1));

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
