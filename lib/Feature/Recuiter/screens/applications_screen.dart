import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Authentication/user_provider.dart';
import 'package:jobapp/Feature/Recuiter/provider/application_provider.dart';
import 'package:jobapp/Feature/combomodel/application_model.dart';
import 'package:jobapp/Feature/combomodel/jobupload_model.dart';
import 'package:jobapp/core/util/appcolors.dart';
class ApplicationsScreen extends ConsumerStatefulWidget {
  final JobModel? job; // Make it optional again
  const ApplicationsScreen({super.key, this.job});
  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}
class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugInitialState();
    });
  }

  void _debugInitialState() {
    log('=== APPLICATIONS SCREEN DEBUG ===');
    // log('Recruiter Email: $recruiterEmail');
    // log('Job passed to screen: ${widget.job?.toMap()}');
    // log('Job ID: ${widget.job?.id}');
    // log('==============================');
  }
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final recruiterEmail = ref.watch(currentRecruiterUserEmailProvider);

    log('=== BUILD DEBUG ===');
    log('Recruiter Email in build: $recruiterEmail');
    log('Widget.job in build: ${widget.job?.designation}');
    return Scaffold(
      appBar: AppBar(
        title: widget.job != null
            ? Text('Applications',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.black,
              fontWeight: FontWeight.w500
            ),
            )
            : const Text('All Applications'),
        backgroundColor: AppColors.faintbackblue,
      ),
      body: _buildBody(recruiterEmail, height,width),
    );
  }
Widget _buildDebugInfo(String recruiterEmail) {
  return Consumer(
    builder: (context, ref, child) {
      final queryParams = _getQueryParams(recruiterEmail);
      final applicationsAsync = ref.watch(applicationsProvider(queryParams));
      return applicationsAsync.when(
        loading: () => Card(
          color: Colors.blue[50],
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🔍 DEBUG INFO - LOADING', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Recruiter: $recruiterEmail'),
                Text('Job ID: ${widget.job?.id ?? "All Jobs"}'),
                Text('Query Path: recruiters/$recruiterEmail/jobs/${widget.job?.id}/applications'),
              ],
            ),
          ),
        ),
        error: (error, stack) => Card(
          color: Colors.red[50],
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('❌ DEBUG INFO - ERROR', 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                Text('Recruiter: $recruiterEmail'),
                Text('Job ID: ${widget.job?.id ?? "All Jobs"}'),
                Text('Error: $error'),
                Text('Stack: $stack'),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.refresh(applicationsProvider(queryParams)),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (applications) => Card(
          color: Colors.green[50],
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✅ DEBUG INFO - SUCCESS', 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text('Recruiter: $recruiterEmail'),
                Text('Job ID: ${widget.job?.id ?? "All Jobs"}'),
                Text('Applications Found: ${applications.length}'),
                if (applications.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text('Sample Application:'),
                  Text('- Name: ${applications.first.jobseekerName}'),
                  Text('- Status: ${applications.first.status}'),
                  Text('- Job ID: ${applications.first.jobId}'),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
  Widget _buildBody(String recruiterEmail, double height,double width) {
    if (recruiterEmail.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Recruiter email not found',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
          _buildDebugInfo(recruiterEmail),
          ],
        ),
      );
    }
    // If no job is provided, show all applications
    if (widget.job == null) {
      return _buildAllApplicationsView(recruiterEmail, height,width);
    }
    // If job is provided, show job-specific applications
    return _buildJobSpecificApplicationsView(recruiterEmail, height,width);
  }
  Widget _buildAllApplicationsView(String recruiterEmail, double height,double width) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Applications',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: height * 0.01),
          Expanded(
            child: _buildAllApplicationsList(recruiterEmail,height,width),),
        ],
      ),
    );
  }
  Widget _buildJobSpecificApplicationsView(
    String recruiterEmail,
    double height,
    double width
  ) {
    return Padding(
      padding:EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Details Section
          _buildJobDetailsSection(widget.job!,height,width),
          SizedBox(height: height * 0.02),

          // Application Statistics
          _buildStatisticsSection(recruiterEmail,height,width),
          SizedBox(height: height * 0.02),

          Text(
            'Candidates Applied for this Job',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: height * 0.01),

          // Applications List
          Expanded(child: _buildJobSpecificApplicationsList(recruiterEmail,height,width)),
        ],
      ),
    );
  }

  Widget _buildJobDetailsSection(JobModel job,double height,double width) {
    return Card(
      elevation: 3,
      child: Padding(
        padding:EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: width*0.1,
                  height: height*0.05,
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
                                Icons.business,
                                color: Colors.blue[600],
                                size: 20,
                              );
                            },
                          ),
                        )
                      : Icon(Icons.business, color: Colors.blue[600], size: 20),
                ),
                SizedBox(width:width*0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.designation,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height*0.006),
                      Text(
                        job.companyName,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: height*0.01),
            Row(
              children: [
                _buildJobDetailChip(Icons.location_on, job.location,height,width),
                SizedBox(width: 8),
                _buildJobDetailChip(Icons.category, job.category,height,width),
                SizedBox(width: 8),
                _buildJobDetailChip(Icons.work, job.experience,height,width),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetailChip(IconData icon, String text,double height,double width) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width*0.01, vertical: height*0.005),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.red,),
          SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
        ],
      ),
    );
  }

  // Helper method to create query params
  ApplicationsQueryParams _getQueryParams(String recruiterEmail) {
    return ApplicationsQueryParams(
      recruiterEmail: recruiterEmail,
      jobId: widget.job?.id,
    );
  }

  Widget _buildStatisticsSection(String recruiterEmail,double height,double width) {
    final queryParams = _getQueryParams(recruiterEmail);

    return Row(
      children: [
        Consumer(
          builder: (context, ref, child) {
            final totalCount = ref.watch(
              totalApplicationsProvider(queryParams),
            );
            return _buildAppStatCard(
              'Total',
              totalCount.toString(),
              Colors.blue,
              height,
              width
            );
          },
        ),
        // Pending Applications
        Consumer(
          builder: (context, ref, child) {
            final pendingCount = ref.watch(
              pendingApplicationsProvider(queryParams),
            );
            return _buildAppStatCard(
              'Pending',
              pendingCount.toString(),
              Colors.orange,
              height,
              width
            );
          },
        ),
        // Shortlisted Applications
        Consumer(
          builder: (context, ref, child) {
            final shortlistedCount = ref.watch(
              shortlistedApplicationsProvider(queryParams),
            );
            return _buildAppStatCard(
              'Shortlisted',
              shortlistedCount.toString(),
              Colors.green,
              height,
              width
            );
          },
        ),
        // Rejected Applications
        Consumer(
          builder: (context, ref, child) {
            final rejectedCount = ref.watch(
              rejectedApplicationsProvider(queryParams),
            );
            return _buildAppStatCard(
              'Rejected',
              rejectedCount.toString(),
              Colors.red,
              height,
              width
            );
          },
        ),
      ],
    );
  }

  Widget _buildJobSpecificApplicationsList(String recruiterEmail,double height,double width) {
    final queryParams = _getQueryParams(recruiterEmail);

    return Consumer(
      builder: (context, ref, child) {
        final applicationsAsync = ref.watch(
          filteredApplicationsProvider(queryParams),
        );

        return applicationsAsync.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error),
          data: (applications) =>
              _buildApplicationsListView(applications, recruiterEmail,height,width),
        );
      },
    );
  }

  Widget _buildAllApplicationsList(String recruiterEmail,double height,double width) {
    final queryParams = ApplicationsQueryParams(recruiterEmail: recruiterEmail);

    return Consumer(
      builder: (context, ref, child) {
        final applicationsAsync = ref.watch(
          filteredApplicationsProvider(queryParams),
        );

        return applicationsAsync.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error),
          data: (applications) =>
              _buildApplicationsListView(applications, recruiterEmail,height,width),
        );
      },
    );
  }

  Widget _buildApplicationsListView(
    List<ApplicationModel> applications,
    String recruiterEmail,
    height,
    width
  ) {
    if (applications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: applications.length,
      itemBuilder: (context, index) {
        return _buildApplicationCard(applications[index], ref, recruiterEmail,height,width);
      },
    );
  }

  Widget _buildApplicationCard(
    ApplicationModel application,
    WidgetRef ref,
    String recruiterEmail,
    double height,
    double width
  ) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Candidate Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getAvatarColor(application.jobseekerName),
                  child: Text(
                    application.jobseekerName.isNotEmpty
                        ? application.jobseekerName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: width*0.015),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.jobseekerName.isNotEmpty
                            ? application.jobseekerName
                            : 'Unknown Candidate',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height*0.002),
                      Text(
                        application.jobseekerEmail,
                        style: TextStyle(fontSize: 10, color: AppColors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.job == null) ...[
                        SizedBox(height: height*0.02),
                        Text(
                          'Job: ${application.jobTitle}',
                          style: TextStyle(fontSize: 11, color: AppColors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 08, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(application.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    application.status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 06,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Application Details
            _buildDetailRow('Applied Date', _formatDate(application.appliedAt),height,width),
            _buildDetailRow('Jobseeker ID', application.jobseekerEmail,height,width),
            SizedBox(height: height*0.013),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue, // Background color blue
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // Optional: rounded corners
                    ),
                    child: InkWell(
                      onTap: () => _viewResume(application.resumeUrl,height,width),
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // Match container border radius
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: height*0.008,
                          horizontal: width*0.02,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.file_present,
                              size: 16,
                              color: Colors.white,
                            ), // White icon
                            SizedBox(width: width*0.008),
                            Text(
                              'View Resume',
                              style: TextStyle(
                                color: Colors.white, // White text
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.06),
                // Status Dropdown
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: application.status,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, size: 20),
                      underline: SizedBox(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (newStatus) {
                        if (newStatus != null) {
                          _updateApplicationStatus(
                            application,
                            newStatus,
                            ref,
                            recruiterEmail,
                            height,
                            width
                          );
                        }
                      },
                      items: [
                        _buildDropdownMenuItem(
                          'pending',
                          'Pending',
                          Colors.orange,
                        ),
                        _buildDropdownMenuItem(
                          'shortlisted',
                          'Shortlisted',
                          Colors.green,
                        ),
                        _buildDropdownMenuItem(
                          'rejected',
                          'Rejected',
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Cover Letter (if available)
            if (application.coverLetter.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                'Cover Letter:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  application.coverLetter,
                  style: TextStyle(fontSize: 11),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownMenuItem(
    String value,
    String text,
    Color color,
  ) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildAppStatCard(String title, String value, Color color,double height,double width) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              SizedBox(height: height*0.003),
              Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  // ignore: deprecated_member_use
                  color: color.withValues(alpha: 0.8),
                ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSpecificJob = widget.job != null;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.grey),
          SizedBox(height: 16),
          Text(
            isSpecificJob
                ? 'No applications for this job yet'
                : 'No applications yet',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            isSpecificJob
                ? 'Candidates will appear here when they apply to this position'
                : 'Applications will appear here when candidates apply to your jobs',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text(
            'Error loading applications',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,double heigth,double width) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: heigth*0.005),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width:width*0.35,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child:
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,                ),
                ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'shortlisted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.grey;
    }
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.indigo,
    ];
    final index = name.isNotEmpty
        ? name.codeUnits.reduce((a, b) => a + b) % colors.length
        : 0;
    return colors[index];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _updateApplicationStatus(
    ApplicationModel application,
    String newStatus,
    WidgetRef ref,
    String recruiterEmail,
    double height,
    double width
  ) async {
    try {
      await ref
          .read(applicationUpdateProvider.notifier)
          .updateApplicationStatus(
            recruiterEmail: recruiterEmail,
            jobId: application.jobId,
            applicationId: application.id,
            newStatus: newStatus,
            ref: ref,
          );
      _showSnackBar(
        // ignore: use_build_context_synchronously
        context: context,
        text: 'Status updated to ${newStatus.toUpperCase()} for ${application.jobseekerName}',
        textColor:newStatus == 'rejected'
                    ? Colors.red
                    :  newStatus == 'shortlisted'
                      ? Colors.green
                    :newStatus =='pending'
                    ?Colors.orange
                    :Colors.black
      );
    } catch (e) {
      _showSnackBar(
        // ignore: use_build_context_synchronously
        context: context,
        text: 'Failed to update status try again',
        textColor: Colors.red,
      );
    }
  }

  void _viewResume(String resumeUrl,double height,double  width) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resume',
        style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14
                ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resume URL:',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12
                ),
            ),
            SizedBox(height: height*0.01),
            SelectableText(
              resumeUrl,
              style: TextStyle(fontSize: 10, color: Colors.blue),
            ),
            SizedBox(height:height*0.02),
            Text('Would you like to download the resume ? Please press 👇.',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11
                ),
            
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(
                context: context,
                text: 'Resume download started',
                textColor: Colors.orange
              );
            },
            child: Text('Download Resume',
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11),
            ),
          ),
        ],
      ),
    );
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
        content: Text(text, 
        style: TextStyle(
          color: textColor,
          fontSize: 10,
        fontWeight: FontWeight.w500),
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
