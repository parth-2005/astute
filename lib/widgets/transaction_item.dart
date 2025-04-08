import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.isPositive;
    final colorScheme = isPositive
        ? AppTheme.positiveColor
        : AppTheme.negativeColor;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPositive
              ? AppTheme.positiveColor.withOpacity(0.1)
              : AppTheme.negativeColor.withOpacity(0.1),
        ),
        child: Icon(
          isPositive ? Icons.arrow_downward : Icons.arrow_upward,
          color: colorScheme,
          size: 20,
        ),
      ),
      title: Text(
        transaction.marketName,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(
        transaction.marketSymbol,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$${transaction.amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme,
                ),
          ),
          Text(
            DateFormat('h:mm a').format(transaction.timestamp),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
} 