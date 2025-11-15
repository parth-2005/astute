import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/market.dart';
import '../../navigation/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/market_card.dart';
import '../../services/firestore_service.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToMarketDetails(Market market) {
    Navigator.pushNamed(
      context,
      AppRouter.marketDetails,
      arguments: market.id,
    );
  }

  List<Market> _filterMarkets(List<Market> markets) {
    if (_searchQuery.isEmpty) {
      return markets;
    }
    return markets.where((market) =>
        market.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        market.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        market.category.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

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
                _buildMarketStreamTab(firestore.getAllMarkets()),
                _buildMarketStreamTab(firestore.getMarketsByCategory('Business')),
                _buildMarketStreamTab(firestore.getMarketsByCategory('Investments')),
                _buildMarketStreamTab(firestore.getMarketsByCategory('IPOs')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketStreamTab(Stream<List<Market>> marketStream) {
    return StreamBuilder<List<Market>>(
      stream: marketStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading contracts'),
          );
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final allMarkets = snapshot.data ?? [];
        final filteredMarkets = _filterMarkets(allMarkets);

        if (filteredMarkets.isEmpty) {
          return const Center(
            child: Text('No contracts found'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredMarkets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final market = filteredMarkets[index];
            return MarketCard(
              market: market,
              onTap: () => _navigateToMarketDetails(market),
            );
          },
        );
      },
    );
  }
}