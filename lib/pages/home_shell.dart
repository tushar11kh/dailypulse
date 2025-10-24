import 'package:dailypulse/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../pages/calendar_page.dart';
import '../pages/trends_page.dart';
import '../pages/summary_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const CalendarPage(),
      const TrendsPage(),
      const SummaryPage(),
    ];

    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DailyPulse'),
        actions: [
            IconButton(
    icon: const Icon(Icons.person_outline),
    tooltip: 'Profile',
    onPressed: () {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
    },
  ),
        ],
      ),
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey[600],
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Trends'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Summary'),
        ],
      ),
    );
  }
}
