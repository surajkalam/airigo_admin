import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jobapp/Authentication/auth_state.dart';

import '../screens/screens.dart';

class RecruiterNavbar extends ConsumerStatefulWidget {
  const RecruiterNavbar({super.key});

  @override
  ConsumerState<RecruiterNavbar> createState() => _RecruiterNavbarState();
}

class _RecruiterNavbarState extends ConsumerState<RecruiterNavbar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    UploadJobsScreen(),
    ApplicationDetailScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Perform logout
                await ref.read(authStateProvider.notifier).signOut();
                // Navigate to login screen
                if (mounted) {
                  context.go('/login'); // Adjust route as needed
                }
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          // If the user taps on the profile tab (index 3) and it's already selected,
          // show the logout dialog
          if (index == 3 && _selectedIndex == 3) {
            _logout();
          } else {
            _onItemTapped(index);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Iconsax.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.add_square),
            label: "Upload Jobs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Applications",
          ),
          BottomNavigationBarItem(icon: Icon(Iconsax.user), label: "Profile"),
        ],
      ),
    );
  }
}
