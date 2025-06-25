import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uas_ambw/config/supabase_config.dart';
import 'package:uas_ambw/providers/auth_provider.dart';
import 'package:uas_ambw/providers/mood_provider.dart';
import 'package:uas_ambw/router/app_router.dart';
import 'package:uas_ambw/services/app_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Debug: Print all shared preferences at app startup
  await AppPreferences.debugPrintAllPreferences();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Mood Journal',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
