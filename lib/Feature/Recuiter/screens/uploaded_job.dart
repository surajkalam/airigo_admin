import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jobapp/Authentication/user_provider.dart';
import 'package:jobapp/Feature/Recuiter/screens/applications_screen.dart';
import 'package:jobapp/Feature/combomodel/jobupload_model.dart';
import 'package:jobapp/core/util/appcolors.dart';

import '../provider/provider.dart';

class UploadJobsScreen extends ConsumerStatefulWidget {
  const UploadJobsScreen({super.key});

  @override
  ConsumerState<UploadJobsScreen> createState() => _UploadJobsScreenState();
}

class _UploadJobsScreenState extends ConsumerState<UploadJobsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Refresh recent jobs when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshRecentJobs();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshRecentJobs() {
    final recruiterEmail = ref.read(currentRecruiterUserEmailProvider);
    if (recruiterEmail.isNotEmpty) {
      ref
          .read(recentJobsNotifierProvider(recruiterEmail).notifier)
          .refreshRecentJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final recruiterEmail = ref.watch(currentRecruiterUserEmailProvider);
    final recentJobsAsync = ref.watch(recentJobsProvider);
    final totalJobsCount = ref.watch(totalJobsCountProvider);
    final activeJobsCount = ref.watch(activeJobsCountProvider);
    final hasRecentJobs = ref.watch(hasRecentJobsProvider);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final colorscheme = Theme.of(context).colorScheme;
    log('=== DEBUG INFO ===');
    log('Recruiter Email: $recruiterEmail');
    // log('Recent Jobs State: ${recentJobsAsync.value}');
    // log('Total Jobs Count: ${totalJobsCount.value}');
    // log('Active Jobs Count: ${activeJobsCount.value}');
    // log('Recent Jobs hasError: ${recentJobsAsync.hasError}');
    // log('Recent Jobs isLoading: ${recentJobsAsync.isLoading}');
    // log('Recent Jobs hasValue: ${recentJobsAsync.hasValue}');
    if (recentJobsAsync.hasError && mounted) {
      _showSnackBar(
        context: context,
        text: '${recentJobsAsync.error}',
        textColor: colorscheme.error,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Jobs'),
        backgroundColor: AppColors.faintbackblue,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: _refreshRecentJobs,
            tooltip: 'Refresh Jobs',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshRecentJobs();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards - Fixed height
              SizedBox(
                height: 100, // Fixed height to prevent overflow
                child: _buildStatisticsCards(totalJobsCount, activeJobsCount),
              ),
              SizedBox(height: height * 0.016),
              // Guidelines Card - Limited height with scroll if needed
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: _buildGuidelinesCard(height, width),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(height: 160, child: _buildUploadSection(height, width)),
              const SizedBox(height: 16),
              // Recent Jobs Header
              _buildRecentJobsHeader(hasRecentJobs, recentJobsAsync),
              const SizedBox(height: 8),
              // Recent Jobs List - Now part of the main scroll
              _buildRecentJobsList(
                recentJobsAsync,
                recruiterEmail,
                height,
                width,
                colorscheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(
    AsyncValue<int> totalJobsCount,
    AsyncValue<int> activeJobsCount,
  ) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.briefcase, color: Colors.blue, size: 16),
                  SizedBox(height: 2),
                  totalJobsCount.when(
                    data: (count) => Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    loading: () => SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (error, stack) => Text(
                      '0',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Total Jobs',
                    style: TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Iconsax.tick_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  activeJobsCount.when(
                    data: (count) => Text(
                      count.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    loading: () => SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (error, stack) => const Text(
                      '0',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Text(
                    'Active Jobs',
                    style: TextStyle(fontSize: 10, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuidelinesCard(double height, double width) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(width * 0.016),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Iconsax.info_circle, color: Colors.blue, size: 18),
                SizedBox(width: 6),
                Text(
                  'Job Upload Guidelines',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildGuidelineItem('Fill all required fields marked with *'),
            _buildGuidelineItem('Upload clear company logo/image'),
            _buildGuidelineItem('Provide accurate CTC information'),
            _buildGuidelineItem('Mention clear job requirements'),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 14),
          SizedBox(width: 6),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 09), softWrap: true),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(double height, double width) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Upload New Job',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: height * 0.003),
            Text(
              'Create a new job posting to attract qualified candidates.',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/uploaddetail-job');
              },
              icon: const Icon(Iconsax.add, size: 16),
              label: const Text(
                'Upload New Job',
                style: TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentJobsHeader(
    bool hasRecentJobs,
    AsyncValue<List<JobModel>> recentJobsAsync,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Uploaded Jobs',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        recentJobsAsync.when(
          data: (jobs) => Chip(
            label: Text(
              '${jobs.length} jobs',
              style: const TextStyle(fontSize: 10),
            ),
            backgroundColor: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          ),
          loading: () => const SizedBox(
            width: 16,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (error, stack) => Chip(
            label: Text('0 jobs', style: TextStyle(fontSize: 10)),
            backgroundColor: Colors.grey[200],
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentJobsList(
    AsyncValue<List<JobModel>> recentJobsAsync,
    String recruiterEmail,
    double height,
    double width,
    ColorScheme colorscheme,
  ) {
    return recentJobsAsync.when(
      data: (jobs) {
        if (jobs.isEmpty) {
          return _buildEmptyState();
        }
        return Column(
          children: [
            ...jobs.map(
              (job) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildJobItem(
                  job,
                  recruiterEmail,
                  height,
                  width,
                  colorscheme,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.warning_2, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                'Error loading jobs',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _refreshRecentJobs,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('Retry', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobItem(
    JobModel job,
    String recruiterEmail,
    double height,
    double width,
    ColorScheme colorscheme,
  ) {
    final jobStatusAsync = ref.watch(jobStatusProvider(job.id));
    final urgentHiringAsync = ref.watch(urgentHiringProvider(job.id));
    return InkWell(
      onLongPress: () {
        _showDeleteDialog(job);
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ApplicationsScreen(job: job)),
        );
      },
      child: Card(
        elevation: 1,
        child: ListTile(
          contentPadding: EdgeInsets.all(8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: job.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      job.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Iconsax.building,
                          color: Colors.blue[600],
                          size: 20,
                        );
                      },
                    ),
                  )
                : Icon(Iconsax.building, color: Colors.blue[600], size: 20),
          ),
          title: SizedBox(
            width: width * 0.42,
            child: Text(
              job.designation,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2),
              SizedBox(
                width: width * 0.42,
                child: Text(
                  job.companyName,
                  style: TextStyle(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Icon(Iconsax.location, size: 10, color: Colors.grey[600]),
                  SizedBox(width: 2),
                  SizedBox(
                    width: width * 0.35,
                    child: Text(
                      job.location,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Iconsax.category, size: 10, color: Colors.grey[600]),
                  SizedBox(width: width * 0.01),
                  SizedBox(
                    width: width * 0.25,
                    child: Text(
                      job.category,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: SizedBox(
            width: 70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Status chip: Active / Inactive
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: job.isActive ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    job.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(color: Colors.white, fontSize: 8),
                  ),
                ),
                urgentHiringAsync.when(
                  data: (isUrgent) => GestureDetector(
                    onTap: () => _toggleUrgentHiring(
                      job.id,
                      isUrgent,
                      recruiterEmail,
                      colorscheme,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isUrgent ? Colors.orange : Colors.grey[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isUrgent ? 'Urgent' : 'Normal',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ),
                  ),
                  loading: () => SizedBox(
                    width: 16,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 1),
                  ),
                  error: (error, stack) => GestureDetector(
                    onTap: () => _refreshUrgentHiring(job.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Error',
                        style: TextStyle(color: Colors.white, fontSize: 4),
                      ),
                    ),
                  ),
                ),

                // SizedBox(height: 1),
                // Text(
                //   _formatTimeAgo(job.createdAt),
                //   style: TextStyle(fontSize: 08, color: Colors.grey[600]),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleUrgentHiring(
    String jobId,
    bool currentStatus,
    String recruiterEmail,
    ColorScheme colorscheme,
  ) {
    ref
        .read(urgentHiringProvider(jobId).notifier)
        .toggleUrgentHiring()
        .then((_) {
          _showSnackBar(
            context: context,
            text: 'Job marked as ${!currentStatus ? 'Urgent' : 'Normal'}',
            backgroundColor: colorscheme.tertiary,
          );
        })
        .catchError((error) {
          _showSnackBar(
            context: context,
            text: 'Failed to update urgent status',
            textColor: colorscheme.error,
          );
        });
  }

  void _refreshUrgentHiring(String jobId) {
    final recruiterEmail = ref.read(currentRecruiterUserEmailProvider);
    if (recruiterEmail.isNotEmpty) {
      ref.invalidate(urgentHiringProvider(jobId));
    }
  }

  void _showDeleteDialog(JobModel job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Job'),
        content: Text(
          'Are you sure you want to delete "${job.designation}" at ${job.companyName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteJob(job.id);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteJob(String jobId) async {
    try {
      final jobNotifier = ref.read(jobNotifierProvider.notifier);
      await jobNotifier.deleteJob(jobId);
      _showSnackBar(
        context: context,
        text: 'Job deleted successfully!',
        textColor: Colors.green,
      );
    } catch (e) {
      _showSnackBar(
        context: context,
        text: 'Failed to delete job',
        textColor: Colors.red,
      );
    }
  }

  //refresh recent jobs
  void _refreshJobStatus(String jobId) {
    final recruiterEmail = ref.read(currentRecruiterUserEmailProvider);
    if (recruiterEmail.isNotEmpty) {
      ref.invalidate(jobStatusProvider(jobId));
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.note_remove, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              const Text(
                'No Jobs Uploaded Yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Start by uploading your first job posting',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now,';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    final weeks = (difference.inDays / 7).floor();
    if (weeks < 4) return '${weeks}w ago';

    final months = (difference.inDays / 30).floor();
    return '${months}m ago';
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
