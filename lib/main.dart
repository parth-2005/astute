import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'navigation/bottom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        StreamProvider<auth.User?>.value(
          value: auth.FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Astute',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print('SplashScreen: Starting initialization...');

    // Check onboarding status
    bool hasSeenOnboarding = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      print('SplashScreen: hasSeenOnboarding = $hasSeenOnboarding');
    } catch (e) {
      print('SplashScreen: Error reading SharedPreferences: $e');
    }

    // Wait for Firebase auth state to stabilize
    auth.User? user;
    try {
      user = auth.FirebaseAuth.instance.currentUser;
      print('SplashScreen: Current user = ${user?.uid ?? "null"}');
      if (user == null) {
        // Wait briefly for auth state to update
        await auth.FirebaseAuth.instance.authStateChanges().first.timeout(
          const Duration(seconds: 1),
          onTimeout: () => null,
        );
        user = auth.FirebaseAuth.instance.currentUser;
        print('SplashScreen: After waiting, user = ${user?.uid ?? "null"}');
      }
    } catch (e) {
      print('SplashScreen: Error checking auth state: $e');
    }

    // Ensure splash screen is shown for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Navigate based on user state and onboarding status
    Widget nextScreen;
    if (user != null) {
      print('SplashScreen: User logged in, navigating to BottomNavBar');
      nextScreen = const BottomNavBar();
    } else if (!hasSeenOnboarding) {
      print('SplashScreen: Onboarding not seen, navigating to OnboardingScreen');
      nextScreen = const OnboardingScreen();
    } else {
      print('SplashScreen: Navigating to LoginScreen');
      nextScreen = const LoginScreen();
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    } else {
      print('SplashScreen: Widget not mounted, skipping navigation');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/app_icon.png'),
            ],
          ),
        ),
      ),
    );
  }
}