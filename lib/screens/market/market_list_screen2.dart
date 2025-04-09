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
      id: '1',
      name: 'Will RVNL close above ₹350.30 on April 8th, 2024?',
      description: 'This market will resolve to "Yes" if RVNL stock closes above ₹350.30 on April 8th, 2024.',
      category: 'Stocks',
      resolutionTime: DateTime(2024, 4, 8, 15, 30),
      yesPrice: 0.65,
      noPrice: 0.35,
      liquidity: 50000,
      volume: 56390,
    ),
    Market(
      id: '2',
      name: 'Will BJP win more than 300 seats in 2024 Lok Sabha elections?',
      description: 'This market will resolve to "Yes" if BJP wins more than 300 seats in the 2024 Lok Sabha elections.',
      category: 'Politics',
      resolutionTime: DateTime(2024, 6, 4, 17, 0),
      yesPrice: 0.72,
      noPrice: 0.28,
      liquidity: 100000,
      volume: 75000,
    ),
    Market(
      id: '3',
      name: 'Will India win more than 70 medals in 2024 Olympics?',
      description: 'This market will resolve to "Yes" if India wins more than 70 medals in the 2024 Olympics.',
      category: 'Sports',
      resolutionTime: DateTime(2024, 8, 11, 23, 59),
      yesPrice: 0.45,
      noPrice: 0.55,
      liquidity: 75000,
      volume: 45000,
    ),
    Market(
      id: '4',
      name: 'Will RBI increase repo rate in April 2024?',
      description: 'This market will resolve to "Yes" if RBI increases the repo rate in its April 2024 monetary policy meeting.',
      category: 'Economy',
      resolutionTime: DateTime(2024, 4, 5, 10, 0),
      yesPrice: 0.38,
      noPrice: 0.62,
      liquidity: 80000,
      volume: 35000,
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
        title: const Text('Markets'),
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
                hintText: 'Search markets',
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
                    .where((market) => market.category == 'Stocks')
                    .toList()),
                _buildMarketList(_filteredMarkets
                    .where((market) => market.category == 'Politics')
                    .toList()),
                _buildMarketList(_filteredMarkets
                    .where((market) => market.category == 'Sports')
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