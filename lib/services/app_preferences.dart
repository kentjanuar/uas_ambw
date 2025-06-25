import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_ambw/config/shared_prefs_keys.dart';

class AppPreferences {
  // Check if it's the first time the app is launched
  static Future<bool> isFirstTimeLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool(SharedPrefsKeys.isFirstTime) ?? true;
    print('DEBUG: isFirstTimeLaunch() => $isFirst');
    return isFirst;
  }

  // Set first time launch to false
  static Future<void> setFirstTimeLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    
    // First clear any existing value to ensure it's reset properly
    await prefs.remove(SharedPrefsKeys.isFirstTime);
    
    // Then set to false
    final success = await prefs.setBool(SharedPrefsKeys.isFirstTime, false);
    print('DEBUG: setFirstTimeLaunchComplete() => isFirstTime set to false, success: $success');
    
    // Verify the value was set correctly
    final currentValue = prefs.getBool(SharedPrefsKeys.isFirstTime);
    print('DEBUG: Current isFirstTime value after setting: $currentValue');
  }

  // Reset first time launch (for testing)
  static Future<void> resetFirstTimeLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharedPrefsKeys.isFirstTime);
    print('DEBUG: resetFirstTimeLaunch() => isFirstTime key removed');
  }
  
  // Debug: Print all shared preferences
  static Future<void> debugPrintAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print('DEBUG: All SharedPreferences:');
    print('isFirstTime: ${prefs.getBool(SharedPrefsKeys.isFirstTime)}');
    print('userSession: ${prefs.getString(SharedPrefsKeys.userSession)}');
    print('userEmail: ${prefs.getString(SharedPrefsKeys.userEmail)}');
    print('userId: ${prefs.getString(SharedPrefsKeys.userId)}');
  }
}
