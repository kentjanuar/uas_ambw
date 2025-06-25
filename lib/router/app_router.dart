import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uas_ambw/providers/auth_provider.dart';
import 'package:uas_ambw/screens/get_started_screen.dart';
import 'package:uas_ambw/screens/home_screen.dart';
import 'package:uas_ambw/screens/sign_in_screen.dart';
import 'package:uas_ambw/screens/sign_up_screen.dart';
import 'package:uas_ambw/services/app_preferences.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static GoRouter get router => _router;
  
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Debug: Print all shared preferences
      await AppPreferences.debugPrintAllPreferences();
      
      final isFirstTimeLaunch = await AppPreferences.isFirstTimeLaunch();
      print('DEBUG Router: isFirstTimeLaunch = $isFirstTimeLaunch, path = ${state.fullPath}');
      
      // If it's the first time launch, show the get started screen
      // But don't redirect if we're already on the get-started screen
      if (isFirstTimeLaunch && state.fullPath != '/get-started') {
        print('DEBUG Router: Redirecting to get-started');
        return '/get-started';
      }
      
      // If user is authenticated, redirect to home
      if (authProvider.isAuthenticated && 
          (state.fullPath == '/signin' || 
           state.fullPath == '/signup' || 
           state.fullPath == '/get-started')) {
        print('DEBUG Router: Authenticated user, redirecting to home');
        return '/';
      }
      
      // If user is not authenticated, redirect to sign in
      if (!authProvider.isAuthenticated && 
          state.fullPath != '/signin' && 
          state.fullPath != '/signup' && 
          state.fullPath != '/get-started') {
        print('DEBUG Router: Unauthenticated user, redirecting to signin');
        return '/signin';
      }
      
      print('DEBUG Router: No redirect needed');
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/get-started',
        name: 'get-started',
        builder: (context, state) => GetStartedScreen(
          onComplete: () {
            context.go('/signin');
          },
        ),
      ),
    ],
  );
}
