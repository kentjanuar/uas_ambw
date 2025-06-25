import 'package:flutter/material.dart';
import 'package:uas_ambw/models/mood_entry.dart';
import 'package:uas_ambw/services/mood_service.dart';

class MoodProvider extends ChangeNotifier {
  final MoodService _moodService = MoodService();
  
  List<MoodEntry> _moodEntries = [];
  bool _isLoading = false;
  String? _error;

  List<MoodEntry> get moodEntries => _moodEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Selected month and year for filtering
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  
  // Set month and year filter
  void setMonthFilter(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
  }

  // Load mood entries for a user, optionally filtered by month
  Future<void> loadMoodEntries(String userId, {int? month, int? year}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    // Use provided month/year or use the selected ones
    final filterMonth = month ?? _selectedMonth;
    final filterYear = year ?? _selectedYear;
    
    try {
      final entries = await _moodService.getMoodEntries(
        userId, 
        month: filterMonth,
        year: filterYear
      );
      _moodEntries = entries.map((e) => MoodEntry.fromJson(e)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new mood entry
  Future<bool> addMoodEntry({
    required String userId,
    required String mood,
    required String date,
    String? note,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _moodService.createMoodEntry(
        userId: userId,
        mood: mood,
        date: date,
        note: note,
      );
      
      if (result == null) {
        // Successfully added, reload the entries
        await loadMoodEntries(userId);
        return true;
      } else {
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
  
  // Delete a mood entry
  Future<bool> deleteMoodEntry(dynamic entryId, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      print('Attempting to delete entry ID: $entryId');
      final result = await _moodService.deleteMoodEntry(entryId);
      
      if (result == null) {
        // Successfully deleted, reload the entries
        await loadMoodEntries(userId);
        return true;
      } else {
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
}
