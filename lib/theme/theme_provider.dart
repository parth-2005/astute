import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  static const String _themePreferenceKey = 'theme_preference';

  ThemeProvider() {
    _loadThemePreference();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeData get theme => _themeMode == ThemeMode.dark 
    ? AppTheme.darkTheme 
    : AppTheme.lightTheme;

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themePreference = prefs.getString(_themePreferenceKey);
    
    if (themePreference == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    
    notifyListeners();
  }
} 