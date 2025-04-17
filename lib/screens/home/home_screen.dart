import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/market.dart';
import '../../navigation/app_router.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/market_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Mock market data (in a real app, this would come from an API)
    final List<Market> trendingMarkets = [
          Market(
  id: 'biz_001',
  name: 'Will Tesla report a profit in Q2 2025?',
  description: 'Tesla is scheduled to release its Q2 earnings. Will the company post a net profit?',
  category: 'Business',
  resolutionTime: DateTime(2025, 7, 30),
  yesPrice: 0.062,
  noPrice: 0.038,
  liquidity: 10000,
  volume: 8500,
),

Market(
  id: 'biz_002',
  name: 'Will Apple launch a new MacBook model by September 2025?',
  description: 'Apple typically hosts its product event in September. Will it announce a new MacBook?',
  category: 'Business',
  resolutionTime: DateTime(2025, 9, 15),
  yesPrice: 0.057,
  noPrice: 0.043,
  liquidity: 8000,
  volume: 6700,
),

Market(
  id: 'biz_003',
  name: 'Will Google face an antitrust fine in 2025?',
  description: 'With regulatory pressure increasing, will Google receive a major fine this year?',
  category: 'Business',
  resolutionTime: DateTime(2025, 12, 31),
  yesPrice: 0.046,
  noPrice: 0.054,
  liquidity: 12000,
  volume: 10450,
),

Market(
  id: 'biz_004',
  name: 'Will OpenAI raise a new funding round in 2025?',
  description: 'Rumors suggest OpenAI may seek new capital. Will it happen this year?',
  category: 'Business',
  resolutionTime: DateTime(2025, 11, 1),
  yesPrice: 0.051,
  noPrice: 0.049,
  liquidity: 9000,
  volume: 7200,
),

Market(
  id: 'biz_005',
  name: 'Will Reliance acquire any startup in 2025?',
  description: 'Reliance has been actively acquiring startups. Will it make a new acquisition this year?',
  category: 'Business',
  resolutionTime: DateTime(2025, 12, 31),
  yesPrice: 0.064,
  noPrice: 0.036,
  liquidity: 9500,
  volume: 7900,
),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/primary_icon0.png',
                          height: 30,
                          width: 30,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Astute",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            themeProvider.isDarkMode 
                                ? Icons.light_mode 
                                : Icons.dark_mode,
                          ),
                          onPressed: () => themeProvider.toggleTheme(),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.marketList);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search),
                        const SizedBox(width: 8),
                        Text(
                          'Search contracts',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Categories'),
              const SizedBox(height: 16),
              _buildCategories(context),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Trending Contracts'),
              const SizedBox(height: 16),
              _buildTrendingMarkets(context, trendingMarkets),
              const SizedBox(height: 24),
              _buildLearningSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.marketList);
            },
            child: const Text('See All'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryCard(
            context,
            'Business',
            Icons.business,
            AppTheme.primaryColor,
            AppRouter.marketList1,
          ),
          const SizedBox(width: 16),
          _buildCategoryCard(
            context,
            'Investments',
            Icons.trending_up,
            AppTheme.primaryColor,
            AppRouter.marketList2,
          ),
          const SizedBox(width: 16),
          _buildCategoryCard(
            context,
            'IPO',
            Icons.monetization_on,
            AppTheme.primaryColor,
            AppRouter.marketList3,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: () {
        // Navigate to category-specific markets
        Navigator.pushNamed(context, route); // Replace with proper category routes
      },
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.black.withOpacity(0.3) : AppTheme.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingMarkets(BuildContext context, List<Market> markets) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: markets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return MarketCard(
          market: markets[index],
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.marketDetails,
              arguments: markets[index].id,
            );
          },
        );
      },
    );
  }

  Widget _buildLearningSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Learning Center'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _buildLearningItem(
                context,
                'Beginners',
                'First step towards financial independence',
                Icons.menu_book,
              ),
              const SizedBox(height: 16),
              _buildLearningItem(
                context,
                'Investors',
                'Learn the fundamentals of investing',
                Icons.account_balance_wallet,
              ),
              const SizedBox(height: 16),
              _buildLearningItem(
                context,
                'Traders',
                'Learn technical fundamentals and strategies',
                Icons.trending_up,
              ),
              const SizedBox(height: 16),
              _buildLearningItem(
                context,
                'Explore App',
                'Guided journey for basic trading',
                Icons.explore,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLearningItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: () {
        // Navigate to specific learning content
        Navigator.pushNamed(context, AppRouter.learningList); // Replace with proper learning routes
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.black.withOpacity(0.3) : AppTheme.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 17) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }
}