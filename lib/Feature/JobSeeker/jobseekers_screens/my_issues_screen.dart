// screens/my_issues_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/combomodel/issue_report_model.dart';
import 'package:jobapp/Feature/JobSeeker/provider/jobaccess_provider.dart';
import 'package:jobapp/Feature/JobSeeker/provider/jobseeker_provider.dart';

class MyIssuesScreen extends ConsumerWidget {
  const MyIssuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final jobseekerState = ref.watch(jobseekerProvider);
    final jobseekerInfo = jobseekerState.jobseekerInfo;
    var height = MediaQuery.of(context).size.height;
    // var width=MediaQuery.of(context).size.width;
    final texttheme = Theme.of(context).textTheme;

    if (jobseekerInfo == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'My Issues & Reports',
            style: texttheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontSize: 14,
            ),
          ),
          backgroundColor: colorScheme.primary.withValues(alpha: 0.7),
        ),
        body: Center(
          child: Text(
            'Please complete your profile to view your issues',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      );
    }
    final issuesAsync = ref.watch(jobseekerIssuesProvider(jobseekerInfo.email));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Issues & Reports',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(jobseekerIssuesProvider(jobseekerInfo.email));
            },
          ),
        ],
      ),
      body: issuesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: colorScheme.onErrorContainer),
              SizedBox(height: height * 0.02),
              Text(
                'Error for loading Issues or Reports ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              SizedBox(height: height * 0.02),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(jobseekerIssuesProvider(jobseekerInfo.email));
                },
                child: Text(
                  'Retry',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        data: (issues) {
          if (issues.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64),
                  SizedBox(height: height * 0.02),
                  Text(
                    'No issues or reports submitted yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    'Any issues or reports you submit will appear here',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return IssueReportCard(issue: issue);
            },
          );
        },
      ),
    );
  }
}

class IssueReportCard extends StatelessWidget {
  final IssueReport issue;

  const IssueReportCard({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    Color statusColor = Colors.orange;
    if (issue.status == 'in_progress') statusColor = Colors.blue;
    if (issue.status == 'resolved') statusColor = Colors.green;

    Color typeColor = issue.type == 'issue' ? Colors.orange : Colors.red;
    IconData typeIcon = issue.type == 'issue'
        ? Icons.warning
        : Icons.report_problem;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: width * 0.028,
        vertical: height * 0.01,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 16),
                ),
                SizedBox(width: width * 0.014),
                Expanded(
                  child: Text(
                    issue.title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(
                    issue.status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: statusColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.01,
                    vertical: height * 0.006,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.01),
            Text(
              issue.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            SizedBox(height: height * 0.011),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: colorScheme.onSecondaryContainer,
                ),
                SizedBox(width: width * 0.02),
                Text(
                  _timeAgo(issue.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                Spacer(),
                Text(
                  issue.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 09,
                    fontWeight: FontWeight.w700,
                    color: typeColor,
                  ),
                ),
              ],
            ),
            // Show admin response if available
            if (issue.adminResponse != null) ...[
              SizedBox(height: height * 0.016),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          statusColor == Colors.green
                              ? Icons.check_circle
                              : Icons.info,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Admin Response',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.006),
                    Text(
                      issue.adminResponse!,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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
