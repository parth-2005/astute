import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';
import '../../navigation/app_router.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final userId = snapshot.data!.uid;
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersTab(userId),
                _buildPositionsTab(userId),
                _buildHistoryTab(userId),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrdersTab(String userId) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return StreamBuilder<List<Order>>(
      stream: firestore.getPendingOrders(userId),
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

  Widget _buildPositionsTab(String userId) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return StreamBuilder<List<Order>>(
      stream: firestore.getUserPositions(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SafeArea(child: Center(child: Text('Error loading positions')));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SafeArea(child: Center(child: CircularProgressIndicator()));
        }

        final executedOrders = snapshot.data ?? [];
        if (executedOrders.isEmpty) {
          return SafeArea(child: _buildEmptyState('No positions', 'Your executed orders will appear here.'));
        }

        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: executedOrders.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final order = executedOrders[index];
              return _buildOrderItem(order);
            },
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(String userId) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return StreamBuilder<List<Order>>(
      stream: firestore.getOrderHistory(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SafeArea(child: Center(child: Text('Error loading order history')));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SafeArea(child: Center(child: CircularProgressIndicator()));
        }

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return SafeArea(child: _buildEmptyState('No order history', 'Your executed or cancelled orders will appear here.'));
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