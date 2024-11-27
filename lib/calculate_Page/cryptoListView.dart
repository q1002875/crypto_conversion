import 'package:crypto_conversion/calculate_Page/crypto_search_page.dart';
import 'package:crypto_conversion/extension/common.dart';

import 'model/trickcrypto.dart';

class CryptoListView extends StatefulWidget {
  final String jsonFileName;
  final String userid;
  final bool iscrypto;
  const CryptoListView(
      {required this.jsonFileName,
      required this.userid,
      required this.iscrypto,
      super.key});

  @override
  _CryptoListViewState createState() => _CryptoListViewState();
}

class _CryptoListViewState extends State<CryptoListView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trickcrypto>>(
      future: loadLocalJson(widget.jsonFileName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return MyListView(widget.userid, snapshot.data!);
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Future<List<Trickcrypto>> loadLocalJson(String fileName) async {
    final String jsonString = await rootBundle.loadString(fileName);
    final List<dynamic> jsonData = json.decode(jsonString);

    List<Trickcrypto> result = [];
    for (final item in jsonData) {
      result.add(Trickcrypto('${item['symbol']}', '${item['id']}',
          '${item['name']}', '${item['image']}',
          iscrypto: widget.iscrypto));
    }
    return result;
  }
}
