// applied_jobs_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/JobSeeker/jobseekers_screens/jobdetailsshow_screen.dart';
import 'package:jobapp/Feature/JobSeeker/provider/application_provider.dart';
import 'package:jobapp/core/util/appcolors.dart';

class AppliedJobsScreen extends ConsumerWidget {
  const AppliedJobsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    TextTheme texttheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Applications',
          style: texttheme.labelMedium?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontSize: 14,
          ),
        ),
        backgroundColor: colorScheme.primary.withValues(alpha: 0.7),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.surfaceContainerHighest],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.06, 0.4],
          ),
        ),
        child: Column(
          children: [
            // Statistics Section
            _buildStatisticsSection(ref, colorScheme, texttheme, height, width),
            SizedBox(height: 16),
            // Applications List
            Expanded(
              child: _buildApplicationsList(
                ref,
                colorScheme,
                texttheme,
                height,
                width,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(
    WidgetRef ref,
    ColorScheme colorscheme,
    TextTheme texttheme,
    double height,
    double width,
  ) {
    final stats = ref.watch(applicationStatsProvider);
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(08),
      decoration: BoxDecoration(
        color: colorscheme.onError,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: colorscheme.secondary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total',
            stats.total,
            colorscheme.onSecondary,
            height,
            width,
          ),
          _buildStatItem(
            'Pending',
            stats.pending,
            colorscheme.tertiary,
            height,
            width,
          ),
          _buildStatItem(
            'Shortlisted',
            stats.shortlisted,
            colorscheme.tertiaryFixed,
            height,
            width,
          ),
          _buildStatItem(
            'Rejected',
            stats.rejected,
            colorscheme.error,
            height,
            width,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    int count,
    Color color,
    double height,
    double width,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: height * 0.01),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationsList(
    WidgetRef ref,
    ColorScheme colorscheme,
    TextTheme texttheme,
    double height,
    double width,
  ) {
    final applicationsAsync = ref.watch(appliedJobsProvider);

    return applicationsAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colorscheme.error, size: 48),
            SizedBox(height: 16),
            Text(
              'Error loading applications',
              style: TextStyle(color: colorscheme.error),
            ),
            SizedBox(height: height * 0.01),
            ElevatedButton(
              onPressed: () => ref.refresh(appliedJobsProvider),
              child: Text(
                'Retry',
                style: texttheme.labelLarge?.copyWith(
                  color: colorscheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
      data: (applications) {
        if (applications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            return _buildApplicationCard(
              context,
              applications[index],
              ref,
              height,
              width,
              colorscheme,
              texttheme,
            );
          },
        );
      },
    );
  }

  Widget _buildApplicationCard(
    BuildContext context,
    Map<String, dynamic> application,
    WidgetRef ref,
    double height,
    double width,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    final jobId = application['job_id'];
    final recruiterEmail = application['recruiter_email'];
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: height * 0.03),
      child: InkWell(
        onTap: () {
          _navigateToJobDetails(context, jobId, recruiterEmail, ref);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(height * 0.018),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      application['job_title'] ?? 'Unknown Job',
                      // style: TextStyle(
                      //   fontSize: 14,
                      //   fontWeight: FontWeight.w600,
                      // ),
                      style: texttheme.labelLarge?.copyWith(
                        color: colorscheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(application['status'] ?? 'pending'),
                ],
              ),
              SizedBox(height: height * 0.01),
              Text(
                'Company: ${application['recruiter_email']?.split('@').first ?? 'Unknown'}',

                style: texttheme.labelMedium?.copyWith(
                  color: colorscheme.secondary,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: AppColors.grey),
                  SizedBox(width: 4),
                  Text(
                    _formatDate(application['applied_at']),
                    style: texttheme.labelMedium?.copyWith(
                      color: colorscheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToJobDetails(
    BuildContext context,
    String jobId,
    String recruiterEmail,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    final jobDetailsFuture = ref
        .read(jobRepositoryProvider)
        .getJobById(jobId, recruiterEmail);

    jobDetailsFuture
        .then((job) {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);

          if (job != null) {
            // Navigate to job details screen
            Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailsScreen(job: job),
              ),
            );
          } else {
            _showSnackBar(
              // ignore: use_build_context_synchronously
              context: context,
              text: 'Job details not found ',
              textColor: Colors.red,
            );
          }
        })
        .catchError((error) {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
          _showSnackBar(
            // ignore: use_build_context_synchronously
            context: context,
            text: 'job details not found ',
            textColor: Colors.red,
          );
        });
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String statusText;
    // ColorScheme colorscheme;
    // TextTheme texttheme;
    switch (status) {
      case 'shortlisted':
        // ignore: deprecated_member_use
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        statusText = 'Shortlisted';
        break;
      case 'rejected':
        // ignore: deprecated_member_use
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        statusText = 'Rejected';
        break;
      default:
        // ignore: deprecated_member_use
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        statusText = 'Pending';
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 06, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 64, color: AppColors.grey),
          SizedBox(height: 16),
          Text(
            'No Applications Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Apply to jobs to see them here',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';

    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return '${date.day}/${date.month}/${date.year}';
      }
      return 'Unknown date';
    } catch (e) {
      return 'Unknown date';
    }
  }

  void _showSnackBar({
    required BuildContext context,
    required String text,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.green,
    Duration duration = const Duration(seconds: 4),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: behavior,
        margin: EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: textColor),
        ),
      ),
    );
  }
}
