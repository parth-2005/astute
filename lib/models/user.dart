class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final double balance;
  final int totalTrades;
  final double profitLoss;
  final double winRate;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.balance,
    required this.totalTrades,
    required this.profitLoss,
    required this.winRate,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    double? balance,
    int? totalTrades,
    double? profitLoss,
    double? winRate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      balance: balance ?? this.balance,
      totalTrades: totalTrades ?? this.totalTrades,
      profitLoss: profitLoss ?? this.profitLoss,
      winRate: winRate ?? this.winRate,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      balance: json['balance'].toDouble(),
      totalTrades: json['total_trades'] as int,
      profitLoss: json['profit_loss'].toDouble(),
      winRate: json['win_rate'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'balance': balance,
      'total_trades': totalTrades,
      'profit_loss': profitLoss,
      'win_rate': winRate,
    };
  }
} 