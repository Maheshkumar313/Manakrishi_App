import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _verificationId;
  String? _pendingName;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        // Assume +919999999999 is admin for testing
        final isAdmin = user.phoneNumber == '+919999999999';
        _currentUser = User(
          id: user.uid,
          phoneNumber: user.phoneNumber ?? user.email ?? '',
          role: isAdmin ? UserRole.admin : UserRole.farmer,
          name: user.displayName ?? _pendingName ?? 'Farmer',
        );
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  String? _redirectPath;
  String? get redirectPath => _redirectPath;

  void setRedirectPath(String? path) {
    _redirectPath = path;
  }

  void clearRedirectPath() {
    _redirectPath = null;
  }

  Future<void> sendOTP(String phoneNumber, {String? name}) async {
    _isLoading = true;
    _pendingName = name;
    notifyListeners();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        verificationCompleted:
            (firebase_auth.PhoneAuthCredential credential) async {
          // Auto code retrieval/resolution Android only
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          _isLoading = false;
          notifyListeners();
          throw Exception(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> verifyOTP(String otp) async {
    if (_verificationId == null) throw Exception('Verification ID is null');

    _isLoading = true;
    notifyListeners();

    try {
      firebase_auth.PhoneAuthCredential credential =
          firebase_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null &&
          _pendingName != null &&
          _pendingName!.isNotEmpty) {
        await userCredential.user!.updateDisplayName(_pendingName);
        // Refresh the user to get the new display name
        await userCredential.user!.reload();
        if (_currentUser != null) {
          _currentUser = User(
            id: _currentUser!.id,
            phoneNumber: _currentUser!.phoneNumber,
            role: _currentUser!.role,
            name: _pendingName,
          );
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return; // User canceled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final firebase_auth.AuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Google Sign-In Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _redirectPath = null;
  }

  // Backwards compatibility method
  Future<void> login(String phoneNumber, {String? name}) async {
    // Should be removed eventually if UI stops calling this directly
  }
}
