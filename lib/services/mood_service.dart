import 'package:supabase_flutter/supabase_flutter.dart';

class MoodService {
  final supabase = Supabase.instance.client;
  final String tableName = 'mood_entries';

  // Create a new mood entry
  Future<String?> createMoodEntry({
    required String userId,
    required String mood,
    required String date,
    String? note,
  }) async {
    try {
      await supabase.from(tableName).insert({
        'user_id': userId,
        'mood': mood,
        'date': date,
        'note': note ?? '',
        'created_at': DateTime.now().toIso8601String(),
      });
      return null; // Success
    } catch (error) {
      return error.toString();
    }
  }

  // Get all mood entries for a user, optionally filtered by month
  Future<List<Map<String, dynamic>>> getMoodEntries(String userId, {int? month, int? year}) async {
    try {
      var query = supabase
          .from(tableName)
          .select()
          .eq('user_id', userId);
      
      // If month and year are provided, filter by that month
      if (month != null && year != null) {
        final monthStr = month.toString().padLeft(2, '0');
        
        // Use a condition that checks if the date string starts with YYYY-MM
        // This will work for both 2025-01-01 and 2025-01-01T10:30:00 formats
        query = query.ilike('date', '$year-$monthStr-%');
        print('Filtering entries for $year-$monthStr (month $month)');
      }
      
      final response = await query.order('date', ascending: false);
      print('Fetched ${response.length} entries');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error fetching mood entries: $error');
      return [];
    }
  }

  // Update a mood entry
  Future<String?> updateMoodEntry({
    required int entryId,
    String? mood,
    String? note,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (mood != null) updates['mood'] = mood;
      if (note != null) updates['note'] = note;
      
      await supabase
          .from(tableName)
          .update(updates)
          .eq('id', entryId);
      
      return null; // Success
    } catch (error) {
      return error.toString();
    }
  }

  // Delete a mood entry
  Future<String?> deleteMoodEntry(dynamic entryId) async {
    try {
      print('Deleting entry with ID: $entryId (Type: ${entryId.runtimeType})');
      
      await supabase
          .from(tableName)
          .delete()
          .eq('id', entryId);
      
      return null; // Success
    } catch (error) {
      print('Error deleting mood entry: $error');
      return error.toString();
    }
  }
}
