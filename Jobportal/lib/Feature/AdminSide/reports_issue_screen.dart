// screens/admin_issues_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/AdminSide/issue_report_datials_screen.dart';
import 'package:jobapp/Feature/AdminSide/model/admin_issuereport.dart';
import 'package:jobapp/Feature/AdminSide/provider/adminissue_provider.dart';

class ReportissueScreen extends ConsumerStatefulWidget {
  const ReportissueScreen({super.key});

  @override
  ConsumerState<ReportissueScreen> createState() => _ReportissueScreenState();
}

class _ReportissueScreenState extends ConsumerState<ReportissueScreen> {
  String _selectedFilter = 'all';
  String _selectedType = 'all';

  final List<String> _statusFilters = [
    'all',
    'pending',
    'in_progress',
    'resolved',
  ];
  final List<String> _typeFilters = ['all', 'issue', 'report'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stats = ref.watch(issuesStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Issues & Reports Management',
          style: TextStyle(fontSize: 14),
        ),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(allIssuesReportsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Cards
          _buildStatisticsCards(stats, colorScheme),

          // Filters
          _buildFilterSection(colorScheme),

          // Issues List
          Expanded(child: _buildIssuesList()),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(
    Map<String, int> stats,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Main Stats Row
          Row(
            children: [
              _buildStatCard(
                'Total',
                stats['total']!.toString(),
                Colors.blue,
                colorScheme,
              ),
              _buildStatCard(
                'Pending',
                stats['pending']!.toString(),
                Colors.orange,
                colorScheme,
              ),
              _buildStatCard(
                'In Progress',
                stats['in_progress']!.toString(),
                Colors.blue,
                colorScheme,
              ),
              _buildStatCard(
                'Resolved',
                stats['resolved']!.toString(),
                Colors.green,
                colorScheme,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Type Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Chip(
                label: Text('Issues: ${stats['issues']}'),
                backgroundColor: Colors.orange.withValues(alpha: 0.2),
              ),
              Chip(
                label: Text('Reports: ${stats['reports']}'),
                backgroundColor: Colors.red.withValues(alpha: 0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 08,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedFilter,
                  items: _statusFilters.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status == 'all'
                            ? 'All Status'
                            : status == 'in_progress'
                            ? 'In Progress'
                            : status.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  items: _typeFilters.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type == 'all' ? 'All Types' : type.toUpperCase(),
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesList() {
    final allIssuesAsync = ref.watch(allIssuesReportsProvider);

    return allIssuesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (issues) {
        final filteredByStatus = _selectedFilter == 'all'
            ? issues
            : issues.where((issue) => issue.status == _selectedFilter).toList();
        final filteredByType = _selectedType == 'all'
            ? filteredByStatus
            : filteredByStatus
                  .where((issue) => issue.type == _selectedType)
                  .toList();
        if (filteredByType.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No issues or reports found'),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: filteredByType.length,
          itemBuilder: (context, index) {
            final issue = filteredByType[index];
            return IssueReportCard(
              issue: issue,
              onTap: () {
                ref.read(selectedIssueProvider.notifier).state = issue;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IssueDetailScreen(issue: issue),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class IssueReportCard extends StatelessWidget {
  final AdminIssuereport issue;
  final VoidCallback onTap;

  const IssueReportCard({super.key, required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color statusColor = Colors.orange;
    if (issue.status == 'in_progress') statusColor = Colors.blue;
    if (issue.status == 'resolved') statusColor = Colors.green;

    Color typeColor = issue.type == 'issue' ? Colors.orange : Colors.red;
    IconData typeIcon = issue.type == 'issue'
        ? Icons.warning
        : Icons.report_problem;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(typeIcon, color: typeColor, size: 20),
        ),
        title: Text(
          issue.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              issue.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  issue.userName,
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Chip(
              label: Text(
                issue.status.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: statusColor,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            ),
            // SizedBox(height: 1),
            // Text(
            //   _timeAgo(issue.createdAt),
            //   style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
            // ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}
