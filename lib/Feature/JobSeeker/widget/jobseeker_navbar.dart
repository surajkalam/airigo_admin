import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
// import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
// import 'package:jobapp/Authentication/auth_state.dart';
import '../jobseekers_screens/jobseekers_screens.dart';

final currentIndexProvider = StateProvider<int>((ref) => 0);

final currentScreenProvider = Provider<Widget>((ref) {
  final index = ref.watch(currentIndexProvider);
  final screens = [
    JobSeekerDashboard(),
    AppliedJobsScreen(),
    JobseekerProfileScreen(),
  ];
  return screens[index];
});

class JobseekerNavbar extends ConsumerWidget {
  const JobseekerNavbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);
    final currentScreen = ref.watch(currentScreenProvider);

    return Scaffold(
      backgroundColor: Color(0xFF1F2937),
      body: currentScreen,
      extendBody: true,
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          bottom: 10,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          color: Color(0xFF374151),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3), // Fixed: use withOpacity instead of withValues
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 70,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 0,
                  currentIndex: currentIndex,
                  activeIcon: Iconsax.home_15,
                  inactiveIcon: Iconsax.home,
                ),
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 1,
                  currentIndex: currentIndex,
                  activeIcon: Iconsax.activity5,
                  inactiveIcon: Iconsax.activity,
                ),
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 2,
                  currentIndex: currentIndex,
                  activeIcon: Iconsax.profile_circle5,
                  inactiveIcon: Iconsax.profile_circle,
                ),
                // _buildLogoutItem(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
    required int currentIndex,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    final isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        ref.read(currentIndexProvider.notifier).state = index;
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? Color(0xFF3B82F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Icon(
            isActive ? activeIcon : inactiveIcon,
            size: 24,
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5), // Fixed: use withOpacity
          ),
        ),
      ),
    );
  }

  // Widget _buildLogoutItem(BuildContext context, WidgetRef ref) {
  //   return GestureDetector(
  //     onTap: () {
  //       _showLogoutDialog(context, ref);
  //     },
  //     child: Container(
  //       width: 48,
  //       height: 48,
  //       decoration: BoxDecoration(
  //         color: Colors.transparent,
  //         borderRadius: BorderRadius.circular(24),
  //       ),
  //       child: Center(
  //         child: Icon(
  //           Icons.logout,
  //           size: 24,
  //           color: Colors.white.withValues(alpha: 0.5),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // void _showLogoutDialog(BuildContext context, WidgetRef ref) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Logout'),
  //         content: Text('Are you sure you want to logout?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.of(context).pop();
  //               // Perform logout
  //               await ref.read(authStateProvider.notifier).signOut();
  //               // Navigate to login screen
  //               if (context.mounted) {
  //                 context.go('/'); // Adjust route as needed
  //               }
  //             },
  //             child: Text('Logout'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}