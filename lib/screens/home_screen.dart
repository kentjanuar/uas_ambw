import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:uas_ambw/models/mood_entry.dart';
import 'package:uas_ambw/providers/auth_provider.dart';
import 'package:uas_ambw/providers/mood_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      
      final defaultMonth = 11; 
      final defaultYear = 2025;
      
      moodProvider.setMonthFilter(defaultMonth, defaultYear);
      
      if (userId != null) {
        moodProvider.loadMoodEntries(
          userId,
          month: defaultMonth,
          year: defaultYear
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF94C973),
      appBar: AppBar(
        backgroundColor: const Color(0xFF94C973),
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'My diary',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.white),
              onPressed: _showUserIdDialog,
              tooltip: 'Copy User ID',
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await authProvider.signOut();
                if (mounted && !authProvider.isAuthenticated) {
                  GoRouter.of(context).go('/signin');
                }
              },
            ),
          ],
        ),
        // Year selector in appbar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildYearButton('2020', moodProvider.selectedYear == 2020),
                _buildYearButton('2021', moodProvider.selectedYear == 2021),
                _buildYearButton('2022', moodProvider.selectedYear == 2022),
                _buildYearButton('2023', moodProvider.selectedYear == 2023),
                _buildYearButton('2024', moodProvider.selectedYear == 2024),
                _buildYearButton('2025', moodProvider.selectedYear == 2025),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _months.map((monthName) => 
                  _buildMonthButton(
                    monthName, 
                    moodProvider.selectedMonth == _monthMap[monthName]
                  )
                ).toList(),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5E8C7), 
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: moodProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : moodProvider.moodEntries.isEmpty
                      ? const Center(
                          child: Text(
                            'No mood entries yet.\nTap the + button to add your first entry!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: moodProvider.moodEntries.length,
                          itemBuilder: (context, index) {
                            final entry = moodProvider.moodEntries[index];
                            return _buildMoodEntryCard(entry);
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          _showAddMoodDialog(context);
        },
        child: const Icon(Icons.add, color: Color(0xFF94C973)),
      ),
    );
  }

  // List of all months
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  
  // Map month name to month number
  final Map<String, int> _monthMap = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12,
  };
  
  Widget _buildMonthButton(String month, bool isSelected) {
    return GestureDetector(
      onTap: () {
        final monthNum = _monthMap[month] ?? DateTime.now().month;
        final moodProvider = Provider.of<MoodProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        final currentYear = moodProvider.selectedYear;
        
        moodProvider.setMonthFilter(monthNum, currentYear);
        
        if (authProvider.userId != null) {
          moodProvider.loadMoodEntries(
            authProvider.userId!,
            month: monthNum,
            year: currentYear
          );
        }
        
        print('Switched to $month ($monthNum), Year: $currentYear');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          month,
          style: TextStyle(
            color: isSelected ? const Color(0xFF94C973) : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildYearButton(String year, bool isSelected) {
    return GestureDetector(
      onTap: () {
        final yearNum = int.parse(year);
        final moodProvider = Provider.of<MoodProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        moodProvider.setMonthFilter(moodProvider.selectedMonth, yearNum);
        
        if (authProvider.userId != null) {
          moodProvider.loadMoodEntries(
            authProvider.userId!,
            month: moodProvider.selectedMonth,
            year: yearNum
          );
        }
        
        print('Switched to year $yearNum, Month: ${moodProvider.selectedMonth}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          year,
          style: TextStyle(
            color: isSelected ? const Color(0xFF94C973) : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMoodEntryCard(MoodEntry entry) {
    // Format date
    final date = DateTime.parse(entry.date);
    final formattedTime = DateFormat('h:mm a').format(date);
    
    Color cardColor = Colors.yellow.shade100; 
    Color circleColor = Colors.blue;
    
    if (entry.mood == '😀' || entry.mood == '😊') {
      circleColor = Colors.blue;
    } else if (entry.mood == '😐') {
      circleColor = Colors.teal;
    } else if (entry.mood == '😔') {
      circleColor = Colors.blue;
    } else if (entry.mood == '😢') {
      circleColor = Colors.orange;
    } else if (entry.mood == '😡') {
      circleColor = Colors.red;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    entry.mood,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sender',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (entry.note != null && entry.note!.isNotEmpty)
                      Text(
                        entry.note!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Delete icon
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  _showDeleteConfirmationDialog(context, entry);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMoodDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    
    final List<String> moodEmojis = ['😀', '😊', '😐', '😔', '😢', '😡'];
    String selectedMood = moodEmojis[0];
    final noteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFFF5E8C7),
              title: const Text(
                'How are you feeling today?',
                style: TextStyle(
                  color: Color(0xFF94C973),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: moodEmojis.map((emoji) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMood = emoji;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedMood == emoji
                                ? const Color(0xFF94C973).withOpacity(0.3)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: selectedMood == emoji
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: 'Add a note (optional)',
                      labelStyle: TextStyle(color: const Color(0xFF94C973)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF94C973)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF94C973), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final userId = authProvider.userId;
                    if (userId != null) {
                      final now = DateTime.now();
                      final today = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').format(now);
                      
                      await moodProvider.addMoodEntry(
                        userId: userId,
                        mood: selectedMood,
                        date: today,
                        note: noteController.text,
                      );
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mood entry added successfully'),
                            backgroundColor: Color(0xFF94C973),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF94C973),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, MoodEntry entry) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text('Are you sure you want to delete this mood entry?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (authProvider.userId != null) {
                  // Debug info
                  print('Deleting entry: ID=${entry.id}, Type=${entry.id.runtimeType}');
                  
                  // Try delete with the ID as is
                  try {
                    await moodProvider.deleteMoodEntry(entry.id, authProvider.userId!);
                    if (context.mounted) {
                      Navigator.pop(context);
                      
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Entry deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    print('Delete error: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting entry: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Method to show user ID for easy copying
  void _showUserIdDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Your User ID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Copy this ID to use in SQL queries:'),
              const SizedBox(height: 10),
              SelectableText(userId ?? 'Not signed in'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
