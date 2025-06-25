import 'package:flutter/material.dart';
import 'package:uas_ambw/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  String? _userId;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _userId;
  String? get userEmail => _userEmail;

  AuthProvider() {
    checkAuthStatus();
  }

  // Check if the user is already authenticated
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    final isLoggedIn = await _authService.restoreSession();
    
    if (isLoggedIn) {
      _isAuthenticated = true;
      _userId = _authService.getCurrentUserId();
      _userEmail = _authService.getCurrentUserEmail();
    } else {
      _isAuthenticated = false;
      _userId = null;
      _userEmail = null;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Sign up with email and password
  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _authService.signUp(email, password);
      
      // If result is null, sign up was successful with no email confirmation required
      if (result == null) {
        _isAuthenticated = true;
        _userId = _authService.getCurrentUserId();
        _userEmail = _authService.getCurrentUserEmail();
        _isLoading = false;
        notifyListeners();
        return true;
      } 
      // If result contains "check your email", sign up was successful but requires email confirmation
      else if (result.contains("check your email")) {
        _error = result; // This is not really an error, but a notification
        _isLoading = false;
        notifyListeners();
        return true; // Return true to indicate successful registration even though email confirmation is required
      }
      // Otherwise it's an actual error
      else {
        _error = result;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await _authService.signIn(email, password);
    
    if (result == null) {
      _isAuthenticated = true;
      _userId = _authService.getCurrentUserId();
      _userEmail = _authService.getCurrentUserEmail();
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = result;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    await _authService.signOut();
    
    _isAuthenticated = false;
    _userId = null;
    _userEmail = null;
    _isLoading = false;
    notifyListeners();
  }
}
