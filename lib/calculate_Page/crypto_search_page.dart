import 'dart:async';

import 'package:crypto_conversion/calculate_Page/cryptoListView.dart';
import 'package:crypto_conversion/extension/common.dart';
import 'package:crypto_conversion/extension/cryptoCache.dart';
import 'package:crypto_conversion/extension/currencyData.dart';
import 'package:crypto_conversion/extension/currencyFlagCacheManager.dart';

import 'model/trickcrypto.dart';

class CryptoSearchPage extends StatefulWidget {
  final String userid;
  const CryptoSearchPage(this.userid, {super.key});

  @override
  State<CryptoSearchPage> createState() => _CryptoSearchPageState();
}

class MyListView extends StatefulWidget {
  final String userId;
  final List<Trickcrypto> data;
  const MyListView(this.userId, this.data, {super.key});

  @override
  _MyListViewState createState() => _MyListViewState();
}

class _CryptoSearchPageState extends State<CryptoSearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: SizedBox.shrink());
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          CryptoListView(
            jsonFileName: 'assets/coindata.json',
            userid: widget.userid,
            iscrypto: true,
            key: const PageStorageKey('crypto'),
          ),
          CryptoListView(
            jsonFileName: 'assets/country.json',
            userid: widget.userid,
            iscrypto: false,
            key: const PageStorageKey('forex'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 延遲初始化以避免不必要的重建
    Future.microtask(() {
      setState(() => _isInitialized = true);
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text('貨幣搜尋',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            text: "加密貨幣",
          ),
          Tab(text: "外匯貨幣"),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context, null),
      ),
    );
  }
}

class _MyListViewState extends State<MyListView> {
  final List<Trickcrypto> _dataList = [];
  final Set<String> _loadedIds = {}; // 追蹤已加載的項目
  final int _loadedCount = 40;
  bool _isLoading = false;
  String _searchKeyword = '';
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  // 緩存搜索結果
  final Map<String, List<Trickcrypto>> _searchCache = {};

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredList();

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: filteredList.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              final currency = CurrencyData.currencies[index];
              final flagCache = CurrencyFlagCache();
              final localFlagPath =
                  flagCache.getLocalFlagPath(currency['name']);

              if (index < filteredList.length) {
                return _buildCryptoItem(
                    filteredList[index], localFlagPath, currency['image']);
              } else {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // 檢查緩存
      final cachedData =
          CryptoCache.getCachedData(widget.data.hashCode.toString());
      if (cachedData != null && _dataList.isEmpty) {
        setState(() {
          _dataList.addAll(cachedData);
        });
        return;
      }

      // 直接加載所有數據
      final allItems =
          widget.data.where((item) => !_loadedIds.contains(item.id)).toList();

      if (allItems.isNotEmpty) {
        setState(() {
          _dataList.addAll(allItems);
          _loadedIds.addAll(allItems.map((e) => e.id));
        });

        // 更新緩存
        CryptoCache.cacheData(widget.data.hashCode.toString(), _dataList);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchData();
  }

  Widget _buildCryptoItem(
      Trickcrypto data, String? localPath, String imageurl) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Hero(
          tag: 'crypto_${data.id}',
          child: localPath != null
              ? Image.file(File(localPath), width: 64, height: 64)
              : Image.network(data.image, width: 64, height: 64),
        ),
        title: Text(
          data.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(data.coin),
        trailing: widget.userId.isNotEmpty
            ? IconButton(
                icon: Icon(
                    data.isAdd ? Icons.check_circle : Icons.add_circle_outline),
                color: data.isAdd ? Colors.green : Colors.grey,
                onPressed: () => _toggleCryptoSelection(data),
              )
            : null,
        onTap: () => Navigator.pop(context, data),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: _handleSearch,
        decoration: InputDecoration(
          hintText: '搜尋貨幣',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(color: Colors.blue, width: 2.0),
          ),
        ),
      ),
    );
  }

  List<Trickcrypto> _getFilteredList() {
    if (_searchKeyword.isEmpty) {
      return _dataList;
    }

    // 檢查緩存
    if (_searchCache.containsKey(_searchKeyword)) {
      return _searchCache[_searchKeyword]!;
    }

    final filteredList = _dataList
        .where((item) =>
            item.name.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
            item.coin.toLowerCase().contains(_searchKeyword.toLowerCase()))
        .toList();

    // 緩存搜索結果
    _searchCache[_searchKeyword] = filteredList;
    return filteredList;
  }

  void _handleSearch(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _searchKeyword = value);
      }
    });
  }

  void _onScroll() {
    if (!_isLoading &&
        _scrollController.position.pixels >
            _scrollController.position.maxScrollExtent - 500) {
      fetchData();
    }
  }

  void _toggleCryptoSelection(Trickcrypto data) {
    setState(() => data.isAdd = !data.isAdd);
  }
}
