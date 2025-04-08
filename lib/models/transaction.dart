import 'package:intl/intl.dart';

enum TransactionType {
  deposit,
  withdrawal,
  buy,
  sell,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  canceled,
}

class Transaction {
  final String id;
  final String marketId;
  final String marketName;
  final String marketSymbol;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final double price;
  final double totalValue;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.marketId,
    required this.marketName,
    required this.marketSymbol,
    required this.type,
    required this.status,
    required this.amount,
    required this.price,
    required this.totalValue,
    required this.timestamp,
  });

  String get formattedDate {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(timestamp);
  }

  String get formattedTime {
    final formatter = DateFormat('h:mm a');
    return formatter.format(timestamp);
  }

  String get formattedDateTime {
    final formatter = DateFormat('MMM dd, yyyy • h:mm a');
    return formatter.format(timestamp);
  }

  String get typeText {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.buy:
        return 'Buy';
      case TransactionType.sell:
        return 'Sell';
    }
  }

  String get statusText {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.canceled:
        return 'Canceled';
    }
  }

  bool get isPositive => type == TransactionType.deposit || type == TransactionType.sell;

  Transaction copyWith({
    String? id,
    String? marketId,
    String? marketName,
    String? marketSymbol,
    TransactionType? type,
    TransactionStatus? status,
    double? amount,
    double? price,
    double? totalValue,
    DateTime? timestamp,
  }) {
    return Transaction(
      id: id ?? this.id,
      marketId: marketId ?? this.marketId,
      marketName: marketName ?? this.marketName,
      marketSymbol: marketSymbol ?? this.marketSymbol,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      price: price ?? this.price,
      totalValue: totalValue ?? this.totalValue,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      marketId: json['market_id'] as String,
      marketName: json['market_name'] as String,
      marketSymbol: json['market_symbol'] as String,
      type: TransactionType.values[json['type'] as int],
      status: TransactionStatus.values[json['status'] as int],
      amount: json['amount'].toDouble(),
      price: json['price'].toDouble(),
      totalValue: json['total_value'].toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'market_id': marketId,
      'market_name': marketName,
      'market_symbol': marketSymbol,
      'type': type.index,
      'status': status.index,
      'amount': amount,
      'price': price,
      'total_value': totalValue,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 