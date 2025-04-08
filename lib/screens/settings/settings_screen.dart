import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _biometricAuth = true;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _marketUpdates = true;
  String _currency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('App Preferences'),
            _buildSettingSwitch(
              title: 'Dark Mode',
              subtitle: 'Enable dark mode for the app',
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                // In a real app, you'd implement theme switching logic here
              },
            ),
            _buildSettingDropdown(
              title: 'Currency',
              subtitle: 'Choose your preferred currency',
              value: _currency,
              options: const ['USD', 'EUR', 'GBP', 'IDR', 'SGD'],
              onChanged: (value) {
                setState(() {
                  _currency = value!;
                });
              },
            ),
            const Divider(),
            _buildSectionHeader('Security'),
            _buildSettingSwitch(
              title: 'Biometric Authentication',
              subtitle: 'Use fingerprint or face recognition to log in',
              value: _biometricAuth,
              onChanged: (value) {
                setState(() {
                  _biometricAuth = value;
                });
              },
            ),
            ListTile(
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to change password screen
              },
            ),
            const Divider(),
            _buildSectionHeader('Notifications'),
            _buildSettingSwitch(
              title: 'Push Notifications',
              subtitle: 'Receive alerts on your device',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
            ),
            _buildSettingSwitch(
              title: 'Email Notifications',
              subtitle: 'Receive alerts via email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),
            _buildSettingSwitch(
              title: 'Market Updates',
              subtitle: 'Get notified about market changes',
              value: _marketUpdates,
              onChanged: (value) {
                setState(() {
                  _marketUpdates = value;
                });
              },
            ),
            const Divider(),
            _buildSectionHeader('About'),
            ListTile(
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show terms of service
              },
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show privacy policy
              },
            ),
            ListTile(
              title: const Text('Version'),
              trailing: const Text('1.0.0'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSettingDropdown({
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }
} 