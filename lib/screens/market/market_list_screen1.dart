import 'package:flutter/material.dart';
import '../../models/market.dart';
import '../../navigation/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/market_card.dart';

class MarketListScreen1 extends StatefulWidget {
  const MarketListScreen1({super.key});

  @override
  State<MarketListScreen1> createState() => _MarketListScreen1State();
}

class _MarketListScreen1State extends State<MarketListScreen1>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock market data (in a real app, you'd fetch this from an API)
  final List<Market> _allMarkets = [
    Market(
  id: 'biz_001',
  name: 'Will Tesla report a profit in Q2 2025?',
  description: 'Tesla is scheduled to release its Q2 earnings. Will the company post a net profit?',
  category: 'CAT1',
  resolutionTime: DateTime(2025, 7, 30),
  yesPrice: 0.62,
  noPrice: 0.38,
  liquidity: 10000,
  volume: 8500,
),

Market(
  id: 'biz_002',
  name: 'Will Apple launch a new MacBook model by September 2025?',
  description: 'Apple typically hosts its product event in September. Will it announce a new MacBook?',
  category: 'CAT1',
  resolutionTime: DateTime(2025, 9, 15),
  yesPrice: 0.57,
  noPrice: 0.43,
  liquidity: 8000,
  volume: 6700,
),

Market(
  id: 'biz_003',
  name: 'Will Google face an antitrust fine in 2025?',
  description: 'With regulatory pressure increasing, will Google receive a major fine this year?',
  category: 'CAT2',
  resolutionTime: DateTime(2025, 12, 31),
  yesPrice: 0.46,
  noPrice: 0.54,
  liquidity: 12000,
  volume: 10450,
),

Market(
  id: 'biz_004',
  name: 'Will OpenAI raise a new funding round in 2025?',
  description: 'Rumors suggest OpenAI may seek new capital. Will it happen this year?',
  category: 'CAT3',
  resolutionTime: DateTime(2025, 11, 1),
  yesPrice: 0.51,
  noPrice: 0.49,
  liquidity: 9000,
  volume: 7200,
),

Market(
  id: 'biz_005',
  name: 'Will Reliance acquire any startup in 2025?',
  description: 'Reliance has been actively acquiring startups. Will it make a new acquisition this year?',
  category: 'CAT3',
  resolutionTime: DateTime(2025, 12, 31),
  yesPrice: 0.64,
  noPrice: 0.36,
  liquidity: 9500,
  volume: 7900,
),
  ];

  List<Market> _filteredMarkets = [];
  List<Market> _favoriteMarkets = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _filteredMarkets = List.from(_allMarkets);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterMarkets();
    });
  }

  void _filterMarkets() {
    if (_searchQuery.isEmpty) {
      _filteredMarkets = List.from(_allMarkets);
    } else {
      _filteredMarkets = _allMarkets
          .where((market) =>
              market.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              market.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  void _toggleFavorite(Market market) {
    setState(() {
      final index = _allMarkets.indexWhere((m) => m.id == market.id);
      final updatedMarket = _allMarkets[index].copyWith(
        isFavorite: !_allMarkets[index].isFavorite,
      );
      _allMarkets[index] = updatedMarket;

      if (updatedMarket.isFavorite) {
        _favoriteMarkets.add(updatedMarket);
      } else {
        _favoriteMarkets.removeWhere((m) => m.id == updatedMarket.id);
      }

      _filterMarkets();
    });
  }

  void _navigateToMarketDetails(String marketId) {
    Navigator.pushNamed(
      context,
      AppRouter.marketDetails,
      arguments: marketId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contracts'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search contracts',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'CAT 1'),
              Tab(text: 'CAT 2'),
              Tab(text: 'CAT 3'),
            ],
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryColor,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMarketList(_filteredMarkets),
                _buildMarketList(_filteredMarkets
                    .where((market) => market.category == 'CAT1')
                    .toList()),
                _buildMarketList(_filteredMarkets
                    .where((market) => market.category == 'CAT2')
                    .toList()),
                _buildMarketList(_filteredMarkets
                    .where((market) => market.category == 'CAT3')
                    .toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketList(List<Market> markets) {
    if (markets.isEmpty) {
      return const Center(
        child: Text('No contracts found'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: markets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final market = markets[index];
        return MarketCard(
          market: market,
          onTap: () => _navigateToMarketDetails(market.id),
          onFavoriteToggle: () => _toggleFavorite(market),
        );
      },
    );
  }
} 