import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/market.dart';
import '../../navigation/app_router.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/price_history_chart.dart';

class MarketDetailsScreen extends StatefulWidget {
  final String marketId;

  const MarketDetailsScreen({
    super.key,
    required this.marketId,
  });

  @override
  State<MarketDetailsScreen> createState() => _MarketDetailsScreenState();
}

class _MarketDetailsScreenState extends State<MarketDetailsScreen> {
  bool _isFavorite = false;
  late Market _market;
  bool _isLoading = false;

  // Mock price history data
  late List<FlSpot> _yesHistoryData;
  late List<FlSpot> _noHistoryData;

  @override
  void initState() {
    super.initState();
    _loadMarketData();
    _generateMockHistoryData();
  }

  void _loadMarketData() {
    // Mock data - in real app, fetch from API
    _market = Market(
      id: widget.marketId,
      name: 'Will RVNL close above ₹350.30 on April 8th, 2024?',
      description: 'This market will resolve to "Yes" if RVNL stock closes above ₹350.30 on April 8th, 2024.',
      category: 'Stocks',
      resolutionTime: DateTime(2024, 4, 8, 15, 30),
      yesPrice: 0.65,
      noPrice: 0.35,
      liquidity: 50000,
      volume: 56390,
      imageUrl: 'assets/images/rvnl.png',
    );
  }

  void _generateMockHistoryData() {
    final now = DateTime.now();
    final random = DateTime.now().millisecondsSinceEpoch % 1000 / 1000;
    
    // Generate 6 months of daily Yes price data
    _yesHistoryData = List.generate(180, (index) {
      final date = now.subtract(Duration(days: 180 - index));
      double volatility = 0.04 * (1 + 0.5 * (sin(index / 10) + cos(index / 21)));
      
      // Start with the current price and work backwards with some volatility
      double price = _market.yesPrice;
      if (index < 179) {
        // Apply some randomness and trend
        double trend = 0.0002 * (179 - index) * (random > 0.5 ? 1 : -1);
        double noise = (random * 2 - 1) * volatility;
        price = price - trend + noise;
        
        // Ensure price is between 0 and 1
        price = price.clamp(0.1, 0.9);
      }
      
      return FlSpot(date.millisecondsSinceEpoch.toDouble(), price);
    });
    
    // Generate corresponding No price data (roughly 1 - yesPrice, with some variation)
    _noHistoryData = _yesHistoryData.map((spot) {
      double variation = (random * 0.04) - 0.02;
      double noPrice = (1 - spot.y) + variation;
      
      // Ensure price is between 0 and 1
      noPrice = noPrice.clamp(0.1, 0.9);
      
      return FlSpot(spot.x, noPrice);
    }).toList();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _navigateToTradeScreen({required bool isYes}) {
    // Initialize controllers with current prices
    final priceController = TextEditingController(
      text: isYes 
        ? (_market.yesPrice * 10).toStringAsFixed(2)
        : (_market.noPrice * 10).toStringAsFixed(2)
    );
    final quantityController = TextEditingController(
      text: '1',
    );

    double totalAmount = 0.0;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void calculateTotal() {
            final quantity = int.tryParse(quantityController.text) ?? 0;
            final price = double.tryParse(priceController.text) ?? 0.0;
            totalAmount = quantity * price;
          }
          
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isYes ? 'Buy Yes' : 'Buy No',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quantity'),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          keyboardType: TextInputType.number,
                          // initialValue: '1',
                          textAlign: TextAlign.right,
                          onChanged: (value) {
                            setState(() {
                              calculateTotal();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Price'),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixText: '₹',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.right,
                          onChanged: (value) {
                            setState(() {
                              calculateTotal();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount'),
                      Text(
                        '₹${totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement order placement
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isYes ? AppTheme.positiveColor : AppTheme.negativeColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isYes ? 'Buy Yes' : 'Buy No',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('RVNL'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? AppTheme.primaryColor : null,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _market.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _market.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildPriceSection(),
                    const SizedBox(height: 24),
                    Text(
                      'Price History',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    PriceHistoryChart(
                      yesData: _yesHistoryData,
                      noData: _noHistoryData,
                      minY: 0.0,
                      maxY: 1.0,
                      height: 250,
                    ),
                    const SizedBox(height: 24),
                    _buildMarketStats(),
                    const SizedBox(height: 24),
                    _buildCurrentListings(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _navigateToTradeScreen(isYes: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Yes'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _navigateToTradeScreen(isYes: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: AppTheme.primaryColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('No'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${(_market.yesPrice * 10).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.positiveColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'No',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${(_market.noPrice * 10).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.negativeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Probability',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                _market.probability,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          _buildStatRow('Resolution Date', 'Apr 8, 2024 3:30 PM'),
          const SizedBox(height: 8),
          _buildStatRow('Time Left', _market.timeLeft),
          const SizedBox(height: 8),
          _buildStatRow('Volume', '₹${(_market.volume / 100000).toStringAsFixed(2)}L'),
          const SizedBox(height: 8),
          _buildStatRow('Liquidity', '₹${(_market.liquidity / 100000).toStringAsFixed(2)}L'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildCurrentListings() {
    // Mock data for current listings
    final List<Map<String, dynamic>> listings = [
      {
        'type': 'No',
        'price': 4.0,
        'quantity': 100,
        'total': 400.0,
        'time': '2 mins ago',
      },
      {
        'type': 'No',
        'price': 4.2,
        'quantity': 50,
        'total': 210.0,
        'time': '5 mins ago',
      },
      {
        'type': 'Yes',
        'price': 5.8,
        'quantity': 200,
        'total': 1160.0,
        'time': '10 mins ago',
      },
    ];

    // Find the max quantity for scaling the bars
    final maxQuantity = listings.fold<int>(0, (max, listing) => 
      listing['quantity'] > max ? listing['quantity'] : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Listings',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Type',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Price',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Volume',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...listings.map((listing) {
                final barWidth = (listing['quantity'] / maxQuantity) * 0.8;
                final isYes = listing['type'] == 'Yes';
                final barColor = isYes ? AppTheme.positiveColor : AppTheme.negativeColor;
                
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              listing['type'],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: barColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '₹${listing['price'].toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Stack(
                              children: [
                                Container(
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppTheme.dividerColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: barWidth,
                                  child: Container(
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: barColor.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        '${listing['quantity']} units · ₹${listing['total'].toStringAsFixed(0)}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            listing['time'],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement trade with this listing
                            },
                            icon: const Icon(Icons.handshake, size: 16),
                            label: const Text('Trade'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}

// Helper function to add some realistic-looking variation for mock data
double sin(double x) => (x - x * x * x / 6 + x * x * x * x * x / 120 - x * x * x * x * x * x * x / 5040) / 2;
double cos(double x) => (1 - x * x / 2 + x * x * x * x / 24 - x * x * x * x * x * x / 720) / 2; 