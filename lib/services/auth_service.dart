import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uas_ambw/config/shared_prefs_keys.dart';
import 'package:uas_ambw/config/supabase_config.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Sign up with email and password
  Future<String?> signUp(String email, String password) async {
    try {
      print('Attempting to sign up with email: $email');
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      print('Sign up response - User: ${response.user != null}, Session: ${response.session != null}');
      
      // Check if user was created successfully
      if (response.user != null) {
        // Check if email confirmation is required
        if (response.session == null) {
          print('Email confirmation is required');
          // Email confirmation is required
          return "Please check your email to confirm your account";
        } else {
          print('No email confirmation required, saving session');
          // No email confirmation required, save session
          await saveUserSession(response.session!);
          return null; // Success, no error
        }
      } else {
        print('Failed to sign up: No user returned');
        return "Failed to sign up: No user returned";
      }
    } catch (error) {
      print('Sign up error: $error');
      return error.toString();
    }
  }

  // Sign in with email and password
  Future<String?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Save user information to local storage
        await saveUserSession(response.session!);
        return null; // Success, no error
      } else {
        return "Failed to sign in";
      }
    } catch (error) {
      return error.toString();
    }
  }

  // Sign out
  Future<void> signOut() async {
    await supabase.auth.signOut();
    // Clear user information from local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharedPrefsKeys.userSession);
    await prefs.remove(SharedPrefsKeys.userEmail);
    await prefs.remove(SharedPrefsKeys.userId);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final currentSession = supabase.auth.currentSession;
    return currentSession != null && currentSession.isExpired == false;
  }

  // Save user session to SharedPreferences
  Future<void> saveUserSession(Session session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Store session token for future refreshes
      await prefs.setString(SharedPrefsKeys.userSession, session.refreshToken ?? '');
      
      if (session.user.email != null) {
        await prefs.setString(SharedPrefsKeys.userEmail, session.user.email!);
      }
      
      await prefs.setString(SharedPrefsKeys.userId, session.user.id);
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  // Restore user session if it exists
  Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(SharedPrefsKeys.userSession);
      
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Use refreshSession instead of setSession for better handling
          final response = await supabase.auth.refreshSession();
          if (response.session != null) {
            // Save refreshed session
            await saveUserSession(response.session!);
            return true;
          }
        } catch (e) {
          print('Session refresh error: $e');
          // Clear invalid session data
          await prefs.remove(SharedPrefsKeys.userSession);
          await prefs.remove(SharedPrefsKeys.userEmail);
          await prefs.remove(SharedPrefsKeys.userId);
        }
      }
      return false;
    } catch (e) {
      print('Restore session error: $e');
      return false;
    }
  }

  // Get current user ID
  String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return supabase.auth.currentUser?.email;
  }
}
