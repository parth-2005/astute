import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import '../../navigation/app_router.dart';
import '../../theme/app_theme.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _isLoading = true);
      
      // Initialize Google Sign In with a scoped configuration
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );
      
      // Clear any previous sign in
      await googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final auth.OAuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final auth.UserCredential userCredential = 
          await auth.FirebaseAuth.instance.signInWithCredential(credential);
      
      final auth.User? user = userCredential.user;
      if (user == null) {
        throw Exception('No user found after sign in');
      }

      // Navigate based on profile completion
      if (user.displayName == null || user.displayName!.isEmpty) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRouter.completeProfile);
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRouter.main);
      }
    } on auth.FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } on PlatformException catch (e) {
      print('PlatformException: ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Platform error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Error signing in with Google: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToPhoneSignIn() {
    Navigator.pushNamed(context, AppRouter.phoneSignIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Text(
                'Welcome to',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Astute Contracts',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else ...[
                SignInButton(
                  Buttons.google,
                  onPressed: _signInWithGoogle,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                const SizedBox(height: 16),
                // -or-
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'or',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _navigateToPhoneSignIn,
                  child: const Text('Sign in with phone number'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 