import 'package:astute/models/learning.dart';
import 'package:astute/widgets/learning_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/market.dart';
import '../../navigation/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/market_card.dart';

class LearningListScreen extends StatefulWidget {
  const LearningListScreen({super.key});

  @override
  State<LearningListScreen> createState() => _LearningListScreenState();
}

class _LearningListScreenState extends State<LearningListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock market data (in a real app, you'd fetch this from an API)
  final List<Learning> _allMarkets = [
    Learning(
      name: "Get Started",
      image: "",
      description: "Get started with Astute",
    ),
    Learning(
      name: "Get Started",
      image: "",
      description: "Get started with Astute",
    ),
    Learning(
      name: "Get Started",
      image: "",
      description: "Get started with Astute",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(_onSearchChanged);
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
    });
  }

  void _navigateToMarketDetails(String marketId) {
    Navigator.pushNamed(context, AppRouter.marketDetails, arguments: marketId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Paths'),
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
                hintText: 'Search Topics',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
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
          // Market List
          Expanded(child: _buildMarketList(_allMarkets)),
        ],
      ),
    );
  }
Widget _buildMarketList(List<Learning> markets) {
  if (markets.isEmpty) {
    return const Center(child: Text('No markets found'));
  }

  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Markets (${markets.length})',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 8),
        Expanded( // This is key!
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: markets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final market = markets[index];
              return LearningCard(
                learning: market,
                onTap: () async {
                  await launchUrl(
                    Uri.parse(
                        'https://youtube.com/shorts/i9Kl2KbdLLI?si=60HRLi1i--fw259y'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

}
