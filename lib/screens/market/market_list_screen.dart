import 'package:flutter/material.dart';
import '../../models/market.dart';
import '../../navigation/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/market_card.dart';

class MarketListScreen extends StatefulWidget {
  const MarketListScreen({super.key});

  @override
  State<MarketListScreen> createState() => _MarketListScreenState();
}

class _MarketListScreenState extends State<MarketListScreen>
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
  category: 'Business',
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
  category: 'Business',
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
  category: 'Business',
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
  category: 'Business',
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
  category: 'Business',
  resolutionTime: DateTime(2025, 12, 31),
  yesPrice: 0.64,
  noPrice: 0.36,
  liquidity: 9500,
  volume: 7900,
),
Market(
  id: 'inv_001',
  name: 'Will Bitcoin cross \$100,000 by December 2025?',
  description: 'Speculations rise as Bitcoin gains momentum. Will it hit the \$100K mark this year?',
  category: 'Investments',
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
  category: 'Investments',
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
  category: 'Investments',
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
  category: 'Investments',
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
  category: 'Investments',
  resolutionTime: DateTime(2025, 12, 31),
  yesPrice: 0.58,
  noPrice: 0.42,
  liquidity: 9500,
  volume: 8100,
),
Market(
  id: 'ipo_001',
  name: 'Will Ola Electric go public in 2025?',
  description: 'After regulatory filings and buzz, will Ola Electric launch its IPO this year?',
  category: 'IPOs',
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
  category: 'IPOs',
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
  category: 'IPOs',
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
  category: 'IPOs',
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
  category: 'IPOs',
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

  void _navigateToMarketDetails(Market market) {
    Navigator.pushNamed(
      context,
      AppRouter.marketDetails,
      arguments: market,
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
              Tab(text: 'Business'),
              Tab(text: 'Investments'),
              Tab(text: 'IPOs'),
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
                    .where((market) => market.category == 'Business')
                    .toList()),
                _buildMarketList(_filteredMarkets
                    .where((market) => market.category == 'Investments')
                    .toList()),
                _buildMarketList(_filteredMarkets
                    .where((market) => market.category == 'IPOs')
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
        print(market);
        return MarketCard(
          market: market,
          onTap: () => _navigateToMarketDetails(market),
          onFavoriteToggle: () => _toggleFavorite(market),
        );
      },
    );
  }
} 