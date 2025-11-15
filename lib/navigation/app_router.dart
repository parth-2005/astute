import 'package:astute/screens/learning/learning_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/phone_sign_in_screen.dart';
import '../screens/auth/complete_profile_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/market/market_details_screen.dart';
import '../screens/market/market_list_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import 'bottom_nav.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String phoneSignIn = '/phone-sign-in';
  static const String completeProfile = '/complete-profile';
  static const String home = '/';
  static const String marketList = '/market-list';
  static const String marketList1 = '/market-list1';
  static const String marketList2 = '/market-list2';
  static const String marketList3 = '/market-list3';
  static const String learningList = '/learning-list';
  static const String marketDetails = '/market-details';
  static const String orders = '/orders';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String main = '/main';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case phoneSignIn:
        return MaterialPageRoute(builder: (_) => const PhoneSignInScreen());
      case completeProfile:
        return MaterialPageRoute(builder: (_) => const CompleteProfileScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const BottomNavBar());
      case marketList:
        return MaterialPageRoute(builder: (_) => const MarketListScreen());
      case learningList:
        return MaterialPageRoute(builder: (_) => const LearningListScreen());
      case marketDetails:
        final String marketId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MarketDetailsScreen(marketId: marketId),
        );
      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const BottomNavBar());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${routeSettings.name}'),
                ),
              ),
        );
    }
  }
}
