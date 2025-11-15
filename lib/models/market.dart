import 'package:cloud_firestore/cloud_firestore.dart';

class Market {
  final String id;
  final String name;
  final String description;
  final String category;
  final DateTime resolutionTime;
  final double yesPrice;
  final double noPrice;
  final double liquidity;
  final double volume;
  final String? imageUrl;
  final bool isFavorite;
  final bool? isResolved;
  final bool? resolvedValue;

  Market({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.resolutionTime,
    required this.yesPrice,
    required this.noPrice,
    required this.liquidity,
    required this.volume,
    this.imageUrl,
    this.isFavorite = false,
    this.isResolved,
    this.resolvedValue,
  });

  Market copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    DateTime? resolutionTime,
    double? yesPrice,
    double? noPrice,
    double? liquidity,
    double? volume,
    String? imageUrl,
    bool? isFavorite,
    bool? isResolved,
    bool? resolvedValue,
  }) {
    return Market(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      resolutionTime: resolutionTime ?? this.resolutionTime,
      yesPrice: yesPrice ?? this.yesPrice,
      noPrice: noPrice ?? this.noPrice,
      liquidity: liquidity ?? this.liquidity,
      volume: volume ?? this.volume,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      isResolved: isResolved ?? this.isResolved,
      resolvedValue: resolvedValue ?? this.resolvedValue,
    );
  }

  factory Market.fromJson(Map<String, dynamic> json) {
    // resolution_time may come from Firestore as a Timestamp, a String, or already a DateTime
    final rawResolution = json['resolution_time'] ?? json['resolutionTime'] ?? json['resolution_at'];
    DateTime resolution;
    if (rawResolution == null) {
      resolution = DateTime.now();
    } else if (rawResolution is Timestamp) {
      resolution = rawResolution.toDate();
    } else if (rawResolution is DateTime) {
      resolution = rawResolution;
    } else {
      resolution = DateTime.parse(rawResolution.toString());
    }

    return Market(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      resolutionTime: resolution,
      yesPrice: (
          (json['yes_price'] ?? json['yesPrice'] ?? json['yes'] ?? 0)
              as num
      )
          .toDouble(),
      noPrice: (
          (json['no_price'] ?? json['noPrice'] ?? json['no'] ?? 0)
              as num
      )
          .toDouble(),
      liquidity: (
          (json['liquidity'] ?? json['liquidity_amount'] ?? 0)
              as num
      )
          .toDouble(),
      volume: (
          (json['volume'] ?? json['tradeVolume'] ?? 0)
              as num
      )
          .toDouble(),
      imageUrl: (json['image_url'] ?? json['imageUrl']) as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isResolved: json['is_resolved'] as bool?,
      resolvedValue: json['resolved_value'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'resolution_time': resolutionTime.toIso8601String(),
      'yes_price': yesPrice,
      'no_price': noPrice,
      'liquidity': liquidity,
      'volume': volume,
      'image_url': imageUrl,
      'is_favorite': isFavorite,
      'is_resolved': isResolved,
      'resolved_value': resolvedValue,
    };
  }

  String get timeLeft {
    final now = DateTime.now();
    final difference = resolutionTime.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Ending soon';
    }
  }

  String get probability => '${(yesPrice * 10 * 10).toStringAsFixed(1)}%';
} 