import 'package:intl/intl.dart';

enum OrderStatus {
  pending,
  executed,
  cancelled,
  expired,
  rejected,
}

enum OrderSide {
  yes,
  no,
}

class Order {
  final String id;
  final String marketId;
  final String marketName;
  final double quantity;
  final double price;
  final OrderSide side;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? executedAt;
  final double? executedPrice;

  Order({
    required this.id,
    required this.marketId,
    required this.marketName,
    required this.quantity,
    required this.price,
    required this.side,
    required this.status,
    required this.createdAt,
    this.executedAt,
    this.executedPrice,
  });

  double get totalValue => quantity * price;

  String get formattedDate {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(createdAt);
  }

  String get formattedTime {
    final formatter = DateFormat('h:mm a');
    return formatter.format(createdAt);
  }

  String get formattedDateTime {
    final formatter = DateFormat('MMM dd, yyyy • h:mm a');
    return formatter.format(createdAt);
  }

  String get sideText => side == OrderSide.yes ? 'Yes' : 'No';

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.executed:
        return 'Executed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.expired:
        return 'Expired';
      case OrderStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isActive => status == OrderStatus.pending;
  bool get isExecuted => status == OrderStatus.executed;
  bool get isCancelled => status == OrderStatus.cancelled || status == OrderStatus.expired || status == OrderStatus.rejected;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      marketId: json['market_id'] as String,
      marketName: json['market_name'] as String,
      quantity: json['quantity'].toDouble(),
      price: json['price'].toDouble(),
      side: OrderSide.values.firstWhere(
        (e) => e.toString() == 'OrderSide.${json['side']}',
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      executedAt: json['executed_at'] != null
          ? DateTime.parse(json['executed_at'] as String)
          : null,
      executedPrice: json['executed_price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'market_id': marketId,
      'market_name': marketName,
      'quantity': quantity,
      'price': price,
      'side': side.toString().split('.').last,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'executed_at': executedAt?.toIso8601String(),
      'executed_price': executedPrice,
    };
  }
}

class Position {
  final String id;
  final String marketId;
  final String marketName;
  final double quantity;
  final double avgPrice;
  final OrderSide side;
  final DateTime openedAt;
  final double currentPrice;

  Position({
    required this.id,
    required this.marketId,
    required this.marketName,
    required this.quantity,
    required this.avgPrice,
    required this.side,
    required this.openedAt,
    required this.currentPrice,
  });

  double get totalValue => quantity * avgPrice;
  double get currentValue => quantity * currentPrice;
  double get profitLoss => currentValue - totalValue;
  double get profitLossPercentage => (profitLoss / totalValue) * 100;

  String get formattedOpenDate {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(openedAt);
  }

  String get sideText => side == OrderSide.yes ? 'Yes' : 'No';

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] as String,
      marketId: json['market_id'] as String,
      marketName: json['market_name'] as String,
      quantity: json['quantity'].toDouble(),
      avgPrice: json['avg_price'].toDouble(),
      side: OrderSide.values.firstWhere(
        (e) => e.toString() == 'OrderSide.${json['side']}',
      ),
      openedAt: DateTime.parse(json['opened_at'] as String),
      currentPrice: json['current_price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'market_id': marketId,
      'market_name': marketName,
      'quantity': quantity,
      'avg_price': avgPrice,
      'side': side.toString().split('.').last,
      'opened_at': openedAt.toIso8601String(),
      'current_price': currentPrice,
    };
  }
} 