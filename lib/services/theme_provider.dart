import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // الوضع الافتراضي يتبع سيستم الموبايل
  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // ده اللي بيقول للأبلكيشن "حدث ألوانك حالاً!"
  }
}
