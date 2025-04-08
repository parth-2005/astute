import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../navigation/app_router.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock user data (in a real app, this would come from an API)
    final UserProfile user = UserProfile(
      id: '1',
      name: 'Lakshya Saraf',
      email: 'lakshya@example.com',
      profileImageUrl: 'assets/images/avatar.png',
      balance: 1340.56,
      totalTrades: 120,
      profitLoss: 325.20,
      winRate: 68.5,
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, user),
            const SizedBox(height: 24),
            _buildMenuItems(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile user) {
    final isPositivePL = user.profitLoss > 0;
    final plColor = isPositivePL ? AppTheme.positiveColor : AppTheme.negativeColor;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 40.0,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(user.profileImageUrl!),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppTheme.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.white.withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  context,
                  'Total Trades',
                  user.totalTrades.toString(),
                ),
                _buildStatColumn(
                  context,
                  'Win Rate',
                  '${user.winRate.toStringAsFixed(1)}%',
                ),
                _buildStatColumn(
                  context,
                  'P/L',
                  '${isPositivePL ? '+' : ''}${user.profitLoss.toStringAsFixed(2)}',
                  valueColor: plColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.white.withOpacity(0.8),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: valueColor ?? AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Column(
      children: [
        _buildMenuItem(
          context,
          icon: Icons.account_balance_wallet_outlined,
          title: 'Wallet',
          onTap: () {
            Navigator.pushNamed(context, AppRouter.wallet);
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.settings_outlined,
          title: 'Account Settings',
          onTap: () {
            Navigator.pushNamed(context, AppRouter.settings);
          },
        ),
        _buildThemeMenuItem(context, themeProvider),
        _buildMenuItem(
          context,
          icon: Icons.article_outlined,
          title: 'Terms & Conditions',
          onTap: () {
            // Show Terms & Conditions
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.feed_outlined,
          title: 'News & Blogs',
          onTap: () {
            // Navigate to news and blogs
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.headset_mic_outlined,
          title: 'Support',
          onTap: () {
            // Navigate to support
          },
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () async{
              // Handle sign out
                // Clear user data in the app
                await Future.wait([
                auth.FirebaseAuth.instance.signOut(),
                GoogleSignIn().signOut(),
                SharedPreferences.getInstance().then((prefs) => prefs.clear()),
                ]);
                // Navigate to the login screen and clear the navigation stack
                Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.login,
                (Route<dynamic> route) => false,
                );
                // Show a success message
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                content: Text('Successfully signed out.'),
                duration: Duration(seconds: 2),
                ),
                );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.negativeColor,
              foregroundColor: AppTheme.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout),
                const SizedBox(width: 8),
                const Text('Sign Out'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Function() onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildThemeMenuItem(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: Icon(
        themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: AppTheme.primaryColor,
      ),
      title: Text(themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode'),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (_) => themeProvider.toggleTheme(),
        activeColor: AppTheme.primaryColor,
      ),
      onTap: () => themeProvider.toggleTheme(),
    );
  }
} 