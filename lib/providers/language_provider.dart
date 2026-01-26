import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  void toggleLanguage() {
    if (_currentLocale.languageCode == 'en') {
      _currentLocale = const Locale('te');
    } else {
      _currentLocale = const Locale('en');
    }
    notifyListeners();
  }
}
