import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_ambw/config/shared_prefs_keys.dart';
import 'package:uas_ambw/providers/auth_provider.dart';
import 'package:uas_ambw/services/app_preferences.dart';

class GetStartedScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const GetStartedScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  @override
  void initState() {
    super.initState();
    _checkPreferences();
  }

  Future<void> _checkPreferences() async {
    final isFirst = await AppPreferences.isFirstTimeLaunch();
    print('DEBUG GetStartedScreen: initState isFirstTimeLaunch = $isFirst');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    print('DEBUG: _completeOnboarding() called');
    await AppPreferences.setFirstTimeLaunchComplete();
    final isFirst = await AppPreferences.isFirstTimeLaunch();
    print('DEBUG: After setting complete, isFirstTimeLaunch = $isFirst');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPrefsKeys.isFirstTime, false);
    print('DEBUG: Force set isFirstTime to false');
    
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF94C973),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5E8C7), 
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildPage(
                      'Welcome to Mood Journal',
                      'Track your daily moods and emotions to understand yourself better.',
                      Icons.emoji_emotions,
                    ),
                    _buildPage(
                      'Record Your Feelings',
                      'Choose an emoji that represents your mood and add notes about your day.',
                      Icons.edit_note,
                    ),
                    _buildPage(
                      'Track Your Progress',
                      'View your mood history and see patterns in your emotional well-being.',
                      Icons.timeline,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _totalPages,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF94C973),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: const Color(0xFF94C973),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94C973),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
