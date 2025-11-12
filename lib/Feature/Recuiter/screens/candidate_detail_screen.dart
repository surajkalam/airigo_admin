import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Authentication/user_provider.dart';
import 'package:jobapp/Feature/Recuiter/provider/application_provider.dart';
import 'package:jobapp/Feature/combomodel/application_model.dart';
import 'package:jobapp/Feature/combomodel/resumeview_screen.dart';
import 'package:jobapp/core/util/appcolors.dart';

class ApplicationDetailScreen extends ConsumerStatefulWidget {
  const ApplicationDetailScreen({super.key});

  @override
  ConsumerState<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends ConsumerState<ApplicationDetailScreen> {
  String _selectedFilter = 'All';


  @override
  void initState() {
    super.initState();
    _debugInitialState();
  }

  void _debugInitialState() {
    log('=== APPLICATION DETAIL SCREEN DEBUG ===');
    log('Initial Filter: $_selectedFilter');
    log('==============================');
  }

  @override
  Widget build(BuildContext context) {
    final recruiterEmail = ref.watch(currentRecruiterUserEmailProvider);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Applications',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.faintbackblue,
      ),
      body: Column(
        children: [
          // Statistics Section
          _buildStatisticsSection(recruiterEmail, height, width),
          SizedBox(height: height * 0.02),
          
          // Filter Buttons
          _buildFilterButtons(height, width),
          SizedBox(height: height * 0.02),
          
          // Applications List
          Expanded(
            child: _buildApplicationsList(recruiterEmail, height, width),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(String recruiterEmail, double height, double width) {
    final queryParams = ApplicationsQueryParams(recruiterEmail: recruiterEmail);

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Statistics',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: height * 0.01),
          Row(
            children: [
              // Total Applications
              Consumer(
                builder: (context, ref, child) {
                  final totalCount = ref.watch(totalApplicationsProvider(queryParams));
                  return _buildStatCard('Total', totalCount.toString(), Colors.blue, height, width);
                },
              ),
              SizedBox(width: width * 0.02),
              // Pending Applications
              Consumer(
                builder: (context, ref, child) {
                  final pendingCount = ref.watch(pendingApplicationsProvider(queryParams));
                  return _buildStatCard('Pending', pendingCount.toString(), Colors.orange, height, width);
                },
              ),
              SizedBox(width: width * 0.02),
              // Shortlisted Applications
              Consumer(
                builder: (context, ref, child) {
                  final shortlistedCount = ref.watch(shortlistedApplicationsProvider(queryParams));
                  return _buildStatCard('Shortlisted', shortlistedCount.toString(), Colors.green, height, width);
                },
              ),
              SizedBox(width: width * 0.02),
              // Rejected Applications
              Consumer(
                builder: (context, ref, child) {
                  final rejectedCount = ref.watch(rejectedApplicationsProvider(queryParams));
                  return _buildStatCard('Rejected', rejectedCount.toString(), Colors.red, height, width);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, double height, double width) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              SizedBox(height: height * 0.005),
              Text(
                title,
                style: TextStyle(
                  fontSize: 08,
                  fontWeight: FontWeight.w500,
                  color: color.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons(double height, double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width*0.01),
      child: Row(
        children: [
          _buildFilterButton('All', 'All', height, width),
          SizedBox(width: width * 0.02),
          _buildFilterButton('Pending', 'pending', height, width),
          SizedBox(width: width * 0.02),
          _buildFilterButton('Shortlisted', 'shortlisted', height, width),
          SizedBox(width: width * 0.02),
          _buildFilterButton('Rejected', 'rejected', height, width),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String filter, double height, double width) {
    final isSelected = _selectedFilter == filter;
    final color = _getStatusColor(filter);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
          // Update the provider
          ref.read(applicationStatusProvider.notifier).state = filter;
        },
        child: Container(
          height: height * 0.04,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: isSelected ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationsList(String recruiterEmail, double height, double width) {
    if (recruiterEmail.isEmpty) {
      return _buildErrorState('Recruiter email not found. Please login again.');
    }

    final queryParams = ApplicationsQueryParams(recruiterEmail: recruiterEmail);

    return Consumer(
      builder: (context, ref, child) {
        final applicationsAsync = ref.watch(filteredApplicationsProvider(queryParams));

        return applicationsAsync.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error.toString()),
          data: (applications) => _buildApplicationsListView(
            applications,
            recruiterEmail,
            height,
            width,
          ),
        );
      },
    );
  }

  Widget _buildApplicationsListView(
    List<ApplicationModel> applications,
    String recruiterEmail,
    double height,
    double width,
  ) {
    if (applications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        return _buildApplicationCard(
          applications[index],
          recruiterEmail,
          height,
          width,
        );
      },
    );
  }
  Widget _buildApplicationCard(

  ApplicationModel application,
  String recruiterEmail,
  double height,
  double width,
) {
  return GestureDetector(
    onTap: () {
      _showCandidateDetails(application, height, width);
    },
    child: Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Candidate Header with Delete Button
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
                SizedBox(width: width * 0.03),
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
                      SizedBox(height: height * 0.005),
                      Text(
                        application.jobseekerEmail,
                        style: TextStyle(fontSize: 10, color: AppColors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Delete Button
                IconButton(
                  onPressed: () {
                    _deleteApplication(application, recruiterEmail, height, width);
                  },
                  icon: Icon(Icons.delete, size: 18, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                SizedBox(width: width * 0.01),
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(application.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    application.status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.015),
            // Job Details
            Text(
              'Job: ${application.jobTitle}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: height * 0.01),

            // Application Details
            _buildDetailRow('Applied Date', _formatDate(application.appliedAt), height, width),
            _buildDetailRow('Job ID', application.jobId, height, width),
            SizedBox(height: height * 0.01),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: InkWell(
                      // onTap: () => _viewResume(application.resumeUrl, height, width),
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResumeViewerScreen(
                              resumeUrl: application.resumeUrl,
                              resumeFileName: application.jobseekerEmail,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: height * 0.01, horizontal: width * 0.02),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.file_present, size: 14, color: Colors.blue),
                            SizedBox(width: width * 0.01),
                            Text(
                              'View Resume',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.03),

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
                      icon: Icon(Icons.arrow_drop_down, size: 16),
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
                            recruiterEmail,
                            height,
                            width,
                          );
                        }
                      },
                      items: [
                        _buildDropdownMenuItem('pending', 'Pending', Colors.orange),
                        _buildDropdownMenuItem('shortlisted', 'Shortlisted', Colors.green),
                        _buildDropdownMenuItem('rejected', 'Rejected', Colors.red),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Cover Letter (if available)
            if (application.coverLetter.isNotEmpty) ...[
              SizedBox(height: height * 0.015),
              Text(
                'Cover Letter:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: height * 0.005),
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
    ),
  );
}
  void _deleteApplication(
  ApplicationModel application,
  String recruiterEmail,
  double height,
  double width,
) async {
  bool? confirmDelete = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Delete Application',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete this application?',
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: height * 0.01),
          Text(
            'Candidate: ${application.jobseekerName}',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
          Text(
            'Job: ${application.jobTitle}',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: Text(
            'Delete',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );

  if (confirmDelete == true) {
    try {
      // Call your delete method from provider
      // You'll need to create this provider - see step 3 below
      await ref.read(applicationDeleteProvider.notifier).deleteApplication(
        recruiterEmail: recruiterEmail,
        jobId: application.jobId,
        applicationId: application.id,
        ref: ref
      );


      _showSnackBar(
        // ignore: use_build_context_synchronously
        context: context,
        text: 'Application deleted successfully',
        textColor: Colors.green,
      );

      // Refresh the applications list
      ref.invalidate(applicationsProvider);
    } catch (e) {
      _showSnackBar(
        // ignore: use_build_context_synchronously
        context: context,
        text: 'Failed to delete application. Please try again.',
        textColor: Colors.red,
      );
    }
  }
}

  DropdownMenuItem<String> _buildDropdownMenuItem(String value, String text, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, double height, double width) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.003),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.3,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.grey),
          SizedBox(height: 16),
          Text(
            _selectedFilter == 'All' 
                ? 'No applications yet'
                : 'No $_selectedFilter applications',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _selectedFilter == 'All'
                ? 'Applications will appear here when candidates apply to your jobs'
                : 'There are no ${_selectedFilter.toLowerCase()} applications',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _updateApplicationStatus(
    ApplicationModel application,
    String newStatus,
    String recruiterEmail,
    double height,
    double width,
  ) async {
    try {
      await ref.read(applicationUpdateProvider.notifier).updateApplicationStatus(
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
        textColor: _getStatusColor(newStatus),
      );

      // Refresh the applications list
      ref.invalidate(applicationsProvider);
    } catch (e) {
      _showSnackBar(
        // ignore: use_build_context_synchronously
        context: context,
        text: 'Failed to update status. Please try again.',
        textColor: Colors.red,
      );
    }
  }

  // void _viewResume(String resumeUrl, double height, double width) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(
  //         'Resume',
  //         style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Resume URL:',
  //             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
  //           ),
  //           SizedBox(height: height * 0.01),
  //           SelectableText(
  //             resumeUrl,
  //             style: TextStyle(fontSize: 10, color: Colors.blue),
  //           ),
  //           SizedBox(height: height * 0.02),
  //           Text(
  //             'Click the URL to copy and open in browser',
  //             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'Close',
  //             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  void _showCandidateDetails(
  ApplicationModel application,
  double height,
  double width,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                children: [
                  Text(
                    'Candidate Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              SizedBox(height: height * 0.02),

              // Candidate Profile Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getAvatarColor(application.jobseekerName),
                        radius: 25,
                        child: Text(
                          application.jobseekerName.isNotEmpty
                              ? application.jobseekerName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              application.jobseekerName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: height * 0.005),
                            Text(
                              application.jobseekerEmail,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: height * 0.005),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(application.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                application.status.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 09,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              // Application Details Section
              _buildDetailSection('Application Details', [
                _buildDetailItem('Applied Date', _formatDate(application.appliedAt)),
                _buildDetailItem('Job Title', application.jobTitle),
                _buildDetailItem('Job ID', application.jobId),
                _buildDetailItem('Application ID', application.id),
              ], height),

              SizedBox(height: height * 0.02),

              // Resume Section
              _buildDetailSection('Resume', [
                ElevatedButton.icon(
                  // onPressed: () => _viewResume(application.resumeUrl, height, width),
                  onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResumeViewerScreen(
                              resumeUrl: application.resumeUrl,
                              resumeFileName: application.jobseekerEmail,
                            ),
                          ),
                        );
                  },
                  icon: Icon(Icons.file_present, size: 16),
                  label: Text('View Resume'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ], height),

              // Cover Letter Section (if available)
              if (application.coverLetter.isNotEmpty) ...[
                SizedBox(height: height * 0.02),
                _buildDetailSection('Cover Letter', [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      application.coverLetter,
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ], height),
              ],

              SizedBox(height: height * 0.02),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteApplication(application, ref.read(currentRecruiterUserEmailProvider), height, width);
                      },
                      icon: Icon(Icons.delete, size: 16, color: Colors.red),
                      label: Text(
                        'Delete Application',
                        style: TextStyle(color: Colors.red,fontSize: 08),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // You can add contact functionality here
                        _showSnackBar(
                          context: context,
                          text: 'Contact feature coming soon',
                          textColor: Colors.blue,
                        );
                      },
                      icon: Icon(Icons.email, size: 16),
                      label: Text('Contact',
                      style: TextStyle(fontSize: 08),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildDetailSection(String title, List<Widget> children, double height) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: height * 0.01),
      Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    ],
  );
}

Widget _buildDetailItem(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 123,
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
          child: Text(
            value,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
        ),
      ],
    ),
  );
}

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'shortlisted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'all':
        return Colors.blue;
      default:
        return AppColors.grey;
    }
  }

  Color _getAvatarColor(String name) {
    final colors = [Colors.blue, Colors.purple, Colors.teal, Colors.orange, Colors.pink, Colors.indigo];
    final index = name.isNotEmpty ? name.codeUnits.reduce((a, b) => a + b) % colors.length : 0;
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

  void _showSnackBar({
    required BuildContext context,
    required String text,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.green,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: textColor),
        ),
      ),
    );
  }
}