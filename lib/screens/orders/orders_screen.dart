import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';
import '../../navigation/app_router.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Live orders will be provided by FirestoreService -> getPendingOrders()

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Orders'),
            Tab(text: 'Positions'),
            Tab(text: 'History'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOrdersTab(),
            _buildPositionsTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return StreamBuilder<List<Order>>(
      stream: firestore.getPendingOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading orders'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return SafeArea(child: _buildEmptyState('No pending orders', 'Your active orders will appear here.'));
        }

        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderItem(order);
            },
          ),
        );
      },
    );
  }

  Widget _buildPositionsTab() {
    return SafeArea(child: _buildEmptyState('No positions', 'Your open positions will appear here.'));
  }

  Widget _buildHistoryTab() {
    return SafeArea(child: _buildEmptyState('No order history', 'Your order history will appear here.'));
  }

  Widget _buildOrderItem(Order order) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          AppRouter.marketDetails,
          arguments: order.marketId,
        );
      },
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.marketName,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Side',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.sideText,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: order.side == OrderSide.yes 
                              ? AppTheme.positiveColor 
                              : AppTheme.negativeColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.quantity.toString(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${order.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${order.totalValue.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall,
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
                    order.formattedDateTime,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Cancel order
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.negativeColor,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(60, 30),
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPositionItem(Position position) {
    final isProfit = position.profitLoss > 0;
    final profitLossColor = isProfit ? AppTheme.positiveColor : AppTheme.negativeColor;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          AppRouter.marketDetails,
          arguments: position.marketId,
        );
      },
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                position.marketName,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Side',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        position.sideText,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: position.side == OrderSide.yes 
                              ? AppTheme.positiveColor 
                              : AppTheme.negativeColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        position.quantity.toString(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avg. Price',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${position.avgPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Current',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${position.currentPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'P&L',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                            color: profitLossColor,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '₹${position.profitLoss.abs().toStringAsFixed(2)} (${position.profitLossPercentage.abs().toStringAsFixed(2)}%)',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: profitLossColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Close position
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.negativeColor,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(60, 30),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Order order) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          AppRouter.marketDetails,
          arguments: order.marketId,
        );
      },
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.marketName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.statusText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Side',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.sideText,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: order.side == OrderSide.yes 
                              ? AppTheme.positiveColor 
                              : AppTheme.negativeColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.quantity.toString(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${order.executedPrice?.toStringAsFixed(2) ?? order.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${order.totalValue.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Created: ${order.formattedDateTime}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              if (order.executedAt != null)
                Text(
                  'Executed: ${DateFormat('MMM dd, yyyy • h:mm a').format(order.executedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.blue;
      case OrderStatus.executed:
        return AppTheme.positiveColor;
      case OrderStatus.cancelled:
      case OrderStatus.expired:
      case OrderStatus.rejected:
        return AppTheme.negativeColor;
    }
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 