import 'package:flutter/material.dart';
import '../../models/market.dart';
import '../../navigation/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/market_card.dart';

class MarketListScreen3 extends StatefulWidget {
  const MarketListScreen3({super.key});

  @override
  State<MarketListScreen3> createState() => _MarketListScreen3State();
}

class _MarketListScreen3State extends State<MarketListScreen3>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock market data (in a real app, you'd fetch this from an API)
  final List<Market> _allMarkets = [
    Market(
  id: 'ipo_001',
  name: 'Will Ola Electric go public in 2025?',
  description: 'After regulatory filings and buzz, will Ola Electric launch its IPO this year?',
  category: 'CAT9',
  resolutionTime: DateTime(2025, 12, 31),
  yesPrice: 0.61,
  noPrice: 0.39,
  liquidity: 10000,
  volume: 8700,
),

Market(
  id: 'ipo_002',
  name: 'Will SpaceX IPO happen before Q3 2025?',
  description: 'Elon Musk has hinted at an IPO. Will SpaceX take the leap before September?',
  category: 'CAT9',
  resolutionTime: DateTime(2025, 9, 30),
  yesPrice: 0.29,
  noPrice: 0.71,
  liquidity: 8500,
  volume: 7600,
),

Market(
  id: 'ipo_003',
  name: 'Will Swiggy’s IPO be oversubscribed on Day 1?',
  description: 'Swiggy is expected to go public. Will the demand exceed supply on the first day?',
  category: 'CAT9',
  resolutionTime: DateTime(2025, 10, 15),
  yesPrice: 0.67,
  noPrice: 0.33,
  liquidity: 11000,
  volume: 9200,
),

Market(
  id: 'ipo_004',
  name: 'Will Reddit IPO before August 2025?',
  description: 'Will the social platform Reddit go public before August this year?',
  category: 'CAT8',
  resolutionTime: DateTime(2025, 8, 1),
  yesPrice: 0.42,
  noPrice: 0.58,
  liquidity: 6000,
  volume: 5300,
),

Market(
  id: 'ipo_005',
  name: 'Will Zepto IPO at a valuation above \$3B?',
  description: 'Zepto, the 10-minute delivery unicorn, is expected to IPO. Will its valuation exceed \$3 billion?',
  category: 'CAT7',
  resolutionTime: DateTime(2025, 11, 30),
  yesPrice: 0.55,
  noPrice: 0.45,
  liquidity: 7000,
  volume: 6100,
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
              Tab(text: 'CAT 7'),
              Tab(text: 'CAT 8'),
              Tab(text: 'CAT 9'),
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
                    .where((market) => market.category == 'CAT7')
                    .toList()),
                _buildMarketList(_filteredMarkets
                    .where((market) => market.category == 'CAT8')
                    .toList()),
                _buildMarketList(_filteredMarkets
                    .where((market) => market.category == 'CAT9')
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
        child: Text('No markets found'),
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