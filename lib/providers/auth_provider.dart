import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  String? _redirectPath;
  String? get redirectPath => _redirectPath;

  void setRedirectPath(String? path) {
    _redirectPath = path;
    // Do not notify listeners here to avoid unnecessary rebuilds if just setting state
    // but if we need UI to react immediately we might.
    // Usually setting this is preparatory.
  }

  void clearRedirectPath() {
    _redirectPath = null;
  }

  // Mock login - 9999999999 is admin
  Future<void> login(String phoneNumber, {String? name}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // Simulate network

    if (phoneNumber == '9999999999') {
      _currentUser = User(
          id: 'admin1',
          phoneNumber: phoneNumber,
          role: UserRole.admin,
          name: 'Admin');
    } else {
      _currentUser = User(
          id: 'farmer1',
          phoneNumber: phoneNumber,
          role: UserRole.farmer,
          name: name ?? 'Farmer');
    }

    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _redirectPath = null;
    notifyListeners();
  }
}
