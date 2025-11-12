import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/AdminSide/firebase_service.dart/firebase_jobs.dart'
    as jobs;
import 'package:jobapp/Feature/combomodel/jobupload_model.dart';

class AdminRecruiterJobsScreen extends ConsumerStatefulWidget {
  final String recruiterEmail;
  final String recruiterName;

  const AdminRecruiterJobsScreen({
    super.key,
    required this.recruiterEmail,
    required this.recruiterName,
  });
  @override
  ConsumerState<AdminRecruiterJobsScreen> createState() =>
      _AdminRecruiterJobsScreenState();
}

class _AdminRecruiterJobsScreenState
    extends ConsumerState<AdminRecruiterJobsScreen> {
  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(
      jobs.getAllJobsForRecruiterProvider(widget.recruiterEmail),
    );
    final colorScheme = Theme.of(context).colorScheme;
    final texttheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.recruiterName}\'s Jobs',
          style: texttheme.labelMedium?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontSize: 14,
          ),
        ),
        backgroundColor: colorScheme.primary.withValues(alpha: 0.7),
      ),
      body: jobsAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading jobs: $error',
            style: texttheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        data: (jobs) {
          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 60,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No jobs found',
                    style: texttheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return _buildJobCard(job, colorScheme, texttheme);
            },
          );
        },
      ),
    );
  }

  Widget _buildJobCard(
    JobModel job,
    ColorScheme colorScheme,
    TextTheme texttheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.designation,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.companyName,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSecondaryContainer.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.location} • ${job.category}',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.secondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: job.isActive ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.onPrimary),
                  ),
                  child: Text(
                    job.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (!job.isActive)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _activateJob(job),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Activate Job',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _activateJob(JobModel job) async {
    try {
      final jobRepository = jobs.JobRepository();
      await jobRepository.updateJobStatus(job.id, widget.recruiterEmail, true);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job activated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to activate job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
