import 'package:astute/models/learning.dart';
import 'package:astute/widgets/notifications_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock market data (in a real app, you'd fetch this from an API)
  final List<Learning> _allMarkets = [
    Learning(
      name: "Get Started",
      image: "",
      description: "Get started with Astute",
    ),
    Learning(
      name: "Get Started",
      image: "",
      description: "Get started with Astute",
    ),
    Learning(
      name: "Get Started",
      image: "",
      description: "Get started with Astute",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Column(
        children: [
          // Market List
          Expanded(child: _buildMarketList(_allMarkets)),
        ],
      ),
    );
  }
Widget _buildMarketList(List<Learning> markets) {
  if (markets.isEmpty) {
    return const Center(child: Text('No notifications.'));
  }

  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Expanded( // This is key!
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: markets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final market = markets[index];
              return NotificationsCard(
                learning: market,
                onTap: () async {
                  await launchUrl(
                    Uri.parse(
                        'https://youtu.be/xiYR3DVytgI'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}
}