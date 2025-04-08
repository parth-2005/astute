import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 200,
            width: 200,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.white.withOpacity(0.8),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 