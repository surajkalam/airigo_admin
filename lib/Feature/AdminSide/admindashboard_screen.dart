// screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/AdminSide/candidatelist_screen.dart';
import 'package:jobapp/Feature/AdminSide/provider/admininfo_provider.dart';
import 'package:jobapp/Feature/AdminSide/recuiterlist_screen.dart';
import 'package:jobapp/Feature/AdminSide/reports_issue_screen.dart';
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = [
    DashboardHome(),
    RecruitersListScreen(),
    CandidatelistScreen(),
    ReportissueScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title:Text('Admin Dashboard',style: TextStyle(fontSize: 14),),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.onPrimary,
                    radius: 30,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: colorScheme.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(0, Icons.dashboard, 'Dashboard'),
            _buildDrawerItem(1, Icons.business_center, 'Recruiters'),
            _buildDrawerItem(2, Icons.people, 'Candidates'),
            _buildDrawerItem(3, Icons.report_problem, 'Reports & Issues'),
          ],
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        size: isSelected? 20:16,
        
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          fontSize: isSelected? 15 :12,
          
        ),
      ),
      selected: isSelected,
      onTap: () => _onItemTapped(index),
    );
  }
}

// Dashboard Home Widget
class DashboardHome extends ConsumerWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error: $error'),
            ),
            data: (stats) {
              return GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Total Recruiters',
                    stats['totalRecruiters'].toString(),
                    Icons.business_center,
                    Colors.blue,
                    colorScheme,
                  ),
                  _buildStatCard(
                    'Total Job Seekers',
                    stats['totalJobSeekers'].toString(),
                    Icons.people,
                    Colors.green,
                    colorScheme,
                  ),
                  // _buildStatCard(
                  //   'Total Payments',
                  //   '\$${stats['totalPayments']}',
                  //   Icons.payment,
                  //   Colors.orange,
                  //   colorScheme,
                  // ),
                  // _buildStatCard(
                  //   'Active Jobs',
                  //   stats['activeJobs'].toString(),
                  //   Icons.work,
                  //   Colors.purple,
                  //   colorScheme,
                  // ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
           SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 09,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}