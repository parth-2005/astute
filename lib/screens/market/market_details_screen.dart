import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../../models/market.dart';
import '../../models/order.dart';

import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/price_history_chart.dart';
import '../../services/firestore_service.dart';

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
  // All market data now comes directly from Firestore streams

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _navigateToTradeScreen({required bool isYes, required Market market, double? price}) {
    // Initialize controllers with current prices or passed-in tapped price
    final priceController = TextEditingController(
      text: price != null
          ? price.toStringAsFixed(2)
          : (isYes ? (market.yesPrice * 10).toStringAsFixed(2) : (market.noPrice * 10).toStringAsFixed(2)),
    );
    final quantityController = TextEditingController(
      text: '1',
    );

    double totalAmount = priceController.text.isNotEmpty
        ? double.parse(priceController.text) * int.parse(quantityController.text)
        : 0.0;
    
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
                      onPressed: () async {
                        final firestore = Provider.of<FirestoreService>(context, listen: false);
                        final quantity = int.tryParse(quantityController.text) ?? 0;
                        final price = double.tryParse(priceController.text) ?? 0.0;

                        if (quantity <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid quantity')),
                          );
                          return;
                        }
                        if (price <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid price')),
                          );
                          return;
                        }

                        try {
                          await firestore.placeOrder(
                            marketId: market.id,
                            marketName: market.name,
                            isYes: isYes,
                            quantity: quantity,
                            price: price,
                          );
                          if (mounted) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Order placed')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error placing order: $e')),
                          );
                        }
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
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return StreamBuilder<Market>(
      stream: firestore.getMarketById(widget.marketId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Market'),
            ),
            body: const Center(child: Text('Error loading market')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Market'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Market'),
            ),
            body: const Center(child: Text('Market not found')),
          );
        }

        final market = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(market.name),
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
                          market.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildPriceSection(market),
                        const SizedBox(height: 24),
                        Text(
                          'Price History',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: firestore.getMarketPriceHistory(widget.marketId),
                          builder: (context, histSnap) {
                            final list = histSnap.data ?? <Map<String, dynamic>>[];

                            final yesData = <FlSpot>[];
                            final noData = <FlSpot>[];
                            for (var item in list) {
                              final ts = item['timestamp'];
                              DateTime date;
                              if (ts == null) continue;
                              if (ts is DateTime) {
                                date = ts;
                              } else if (ts is fs.Timestamp) {
                                date = ts.toDate();
                              } else {
                                date = DateTime.tryParse(ts.toString()) ?? DateTime.now();
                              }

                              final x = date.millisecondsSinceEpoch.toDouble();
                              final yes = (item['yes'] ?? item['yes_price'] ?? item['yesPrice']) as num? ?? 0.0;
                              final no = (item['no'] ?? item['no_price'] ?? item['noPrice']) as num? ?? 0.0;
                              yesData.add(FlSpot(x, yes.toDouble()));
                              noData.add(FlSpot(x, no.toDouble()));
                            }

                            return PriceHistoryChart(
                              yesData: yesData,
                              noData: noData,
                              minY: 0.0,
                              maxY: 1.0,
                              height: 250,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildMarketStats(market),
                        const SizedBox(height: 24),
                        _buildCurrentListings(market),
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
                      onPressed: () => _navigateToTradeScreen(isYes: true, market: market),
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
                      onPressed: () => _navigateToTradeScreen(isYes: false, market: market),
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
      },
    );
  }

  Widget _buildPriceSection(Market market) {
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
                    '₹${(market.yesPrice * 10).toStringAsFixed(2)}',
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
                    '₹${(market.noPrice * 10).toStringAsFixed(2)}',
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
                market.probability,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketStats(Market market) {
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
          _buildStatRow('Time Left', market.timeLeft),
          const SizedBox(height: 8),
          _buildStatRow('Volume', '₹${(market.volume / 100000).toStringAsFixed(2)}L'),
          const SizedBox(height: 8),
          _buildStatRow('Liquidity', '₹${(market.liquidity / 100000).toStringAsFixed(2)}L'),
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
Widget _buildCurrentListings(Market market) {
  final firestore = Provider.of<FirestoreService>(context, listen: false);

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top stats using live market data
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statItem('YES PRICE', market.yesPrice * 10),
            _statItem('NO PRICE', market.noPrice * 10),
            _statItem('VOLUME', market.volume.toDouble()),
            _statItem('CATEGORY', 0.0, isText: true, textValue: market.category),
          ],
        ),
        const Divider(height: 24),

        const Text('Live Order Book',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

                        // Live order book using StreamBuilder
        StreamBuilder<List<Order>>(
          stream: firestore.getMarketOrderBook(market.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No open orders'),
                ),
              );
            }

            final orders = snapshot.data!;
            final yesOrders = orders.where((o) => o.side == OrderSide.yes).toList();
            final noOrders = orders.where((o) => o.side == OrderSide.no).toList();

            // Aggregate orders by price (normalize to 2 decimals) and sum quantities
            List<Map<String, double>> aggregateByPrice(List<Order> list) {
              final Map<double, double> map = {};
              for (var o in list) {
                final p = double.parse(o.price.toStringAsFixed(2));
                map[p] = (map[p] ?? 0) + o.quantity;
              }
              final result = map.entries.map((e) => {'price': e.key, 'qty': e.value}).toList();
              // sort descending by price (highest on top)
              result.sort((a, b) => (b['price']!).compareTo(a['price']!));
              return result;
            }

            final aggYes = aggregateByPrice(yesOrders);
            final aggNo = aggregateByPrice(noOrders);

            final maxRows = 6;
            final leftList = aggNo.take(maxRows).toList();
            final rightList = aggYes.take(maxRows).toList();

            return Column(
              children: [
                // Header row showing NO (left) and YES (right)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  child: Row(
                    children: [
                      // Expanded(
                      //   child: Column(
                      //     children: [
                      //       const Text('NO', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                      //       const SizedBox(height: 4),
                      //       const Text('QTY', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      //     ],
                      //   ),
                      // ),
                      // Container(width: 1, height: 40, color: Colors.grey.shade200),
                      // Expanded(
                      //   child: Column(
                      //     children: [
                      //       const Text('YES', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                      //       const SizedBox(height: 4),
                      //       const Text('QTY', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      //     ],
                      //   ),
                      // ),
                      Expanded(
                        child: Column(
                          children: const [
                            Text('QTY', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: const [
                            Text('NO', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('PRICE', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: const [
                            Text('YES', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('PRICE', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: const [
                            Text('QTY', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Lists side-by-side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NO column (left)
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: leftList.length,
                        itemBuilder: (context, i) {
                          final item = leftList[i];
                          final price = item['price']!;
                          final qty = item['qty']!;
                          return GestureDetector(
                            onTap: () => _navigateToTradeScreen(isYes: false, market: market, price: price),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(qty.toStringAsFixed(0), textAlign: TextAlign.left),
                                  Text('₹${price.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.negativeColor)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Spacer between columns
                    Container(width: 8),

                    // YES column (right)
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rightList.length,
                        itemBuilder: (context, i) {
                          final item = rightList[i];
                          final price = item['price']!;
                          final qty = item['qty']!;
                          return GestureDetector(
                            onTap: () => _navigateToTradeScreen(isYes: true, market: market, price: price),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('₹${price.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.positiveColor)),
                                  Text(qty.toStringAsFixed(0), textAlign: TextAlign.right),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Total orders shown (max 6 per side). Tap to select price.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    ),
  );
}

  Widget _statItem(String label, double value, {bool isText = false, String? textValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isText ? (textValue ?? '') : value.toStringAsFixed(2),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
} 