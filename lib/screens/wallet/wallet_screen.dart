import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../theme/app_theme.dart';
import '../../widgets/transaction_item.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // Mock data (in a real app, this would come from an API)
  final double _balance = 1340.56;
  
  // Group transactions by date
  final Map<DateTime, List<Transaction>> _transactionsByDate = {
    DateTime(2022, 10, 26): [
      Transaction(
        id: '1',
        marketId: '1',
        marketName: 'Adam Costa',
        marketSymbol: 'Standard Chartered Bank',
        type: TransactionType.deposit,
        status: TransactionStatus.completed,
        amount: 200.0,
        price: 0.0,
        totalValue: 200.0,
        timestamp: DateTime(2022, 10, 26, 17, 2),
      ),
      Transaction(
        id: '2',
        marketId: '2',
        marketName: 'Sarah Eric',
        marketSymbol: 'Payment Received',
        type: TransactionType.deposit,
        status: TransactionStatus.completed,
        amount: 200.0,
        price: 0.0,
        totalValue: 200.0,
        timestamp: DateTime(2022, 10, 26, 15, 22),
      ),
    ],
    DateTime(2022, 10, 25): [
      Transaction(
        id: '3',
        marketId: '3',
        marketName: 'Millie Bobby',
        marketSymbol: 'Payment Received',
        type: TransactionType.deposit,
        status: TransactionStatus.completed,
        amount: 200.0,
        price: 0.0,
        totalValue: 200.0,
        timestamp: DateTime(2022, 10, 25, 15, 22),
      ),
      Transaction(
        id: '4',
        marketId: '4',
        marketName: 'William Edward',
        marketSymbol: 'Payment Received',
        type: TransactionType.deposit,
        status: TransactionStatus.completed,
        amount: 200.0,
        price: 0.0,
        totalValue: 200.0,
        timestamp: DateTime(2022, 10, 25, 15, 22),
      ),
      Transaction(
        id: '5',
        marketId: '1',
        marketName: 'Adam Costa',
        marketSymbol: 'Standard Chartered Bank',
        type: TransactionType.deposit,
        status: TransactionStatus.completed,
        amount: 200.0,
        price: 0.0,
        totalValue: 200.0,
        timestamp: DateTime(2022, 10, 25, 17, 2),
      ),
    ],
  };

  void _depositFunds() {
    // In a real app, this would show a deposit flow
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deposit Funds'),
        content: const Text('This feature is not implemented in the demo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _withdrawFunds() {
    // In a real app, this would show a withdrawal flow
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Funds'),
        content: const Text('This feature is not implemented in the demo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to transaction history
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWalletHeader(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            _buildTransactionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletHeader() {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Earnings',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.white.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(_balance),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _depositFunds,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.white,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Deposit'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _withdrawFunds,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.white,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Withdraw'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    // Sort dates in descending order
    final sortedDates = _transactionsByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('No transactions yet'),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final transactions = _transactionsByDate[date]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                DateFormat('MMM d, yyyy').format(date),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return TransactionItem(transaction: transactions[index]);
              },
            ),
          ],
        );
      },
    );
  }
} 