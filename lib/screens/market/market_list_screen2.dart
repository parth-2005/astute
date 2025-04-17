import 'package:flutter/material.dart';
import '../../models/market.dart';
import '../../navigation/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/market_card.dart';

class MarketListScreen2 extends StatefulWidget {
  const MarketListScreen2({super.key});

  @override
  State<MarketListScreen2> createState() => _MarketListScreen2State();
}

class _MarketListScreen2State extends State<MarketListScreen2>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock market data (in a real app, you'd fetch this from an API)
  final List<Market> _allMarkets = [
    Market(
  id: 'inv_001',
  name: 'Will Bitcoin cross \$100,000 by December 2025?',
  description: 'Speculations rise as Bitcoin gains momentum. Will it hit the \$100K mark this year?',
  category: 'CAT4',
  resolutionTime: DateTime(2025, 12, 31),
  yesPrice: 0.41,
  noPrice: 0.59,
  liquidity: 15000,
  volume: 13800,
),

Market(
  id: 'inv_002',
  name: 'Will the S&P 500 end 2025 above 5500?',
  description: 'Investors watch the index closely amid market volatility.',
  category: 'CAT4',
  resolutionTime: DateTime(2025, 12, 31),
  yesPrice: 0.48,
  noPrice: 0.52,
  liquidity: 13000,
  volume: 11500,
),

Market(
  id: 'inv_003',
  name: 'Will gold cross \$2500/oz in 2025?',
  description: 'Inflation and global tension could drive gold prices up. Will it happen?',
  category: 'CAT4',
  resolutionTime: DateTime(2025, 12, 31),
  yesPrice: 0.53,
  noPrice: 0.47,
  liquidity: 7000,
  volume: 6400,
),

Market(
  id: 'inv_004',
  name: 'Will Berkshire Hathaway outperform the S&P 500 in 2025?',
  description: 'Berkshire’s value investing strategy is in question. Will it beat the index?',
  category: 'CAT5',
  resolutionTime: DateTime(2025, 12, 31),
  yesPrice: 0.44,
  noPrice: 0.56,
  liquidity: 6000,
  volume: 5200,
),

Market(
  id: 'inv_005',
  name: 'Will Indian Mutual Fund AUM exceed ₹60L crore by year-end?',
  description: 'With increasing SIPs and retail interest, will mutual fund assets grow to this level?',
  category: 'CAT6',
  resolutionTime: DateTime(2025, 12, 31),
  yesPrice: 0.58,
  noPrice: 0.42,
  liquidity: 9500,
  volume: 8100,
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
              Tab(text: 'CAT 4'),
              Tab(text: 'CAT 5'),
              Tab(text: 'CAT 6'),
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
                    .where((market) => market.category == 'CAT4')
                    .toList()),
                _buildMarketList(_filteredMarkets
                    .where((market) => market.category == 'CAT5')
                    .toList()),
                _buildMarketList(_filteredMarkets
                    .where((market) => market.category == 'CAT6')
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