import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jobapp/Feature/JobSeeker/modelclass/jobseeker_info.dart';
import 'package:jobapp/Feature/JobSeeker/provider/application_provider.dart';
import 'package:jobapp/Feature/JobSeeker/provider/jobseeker_provider.dart';
import 'package:jobapp/Feature/combomodel/jobupload_model.dart';
import 'package:jobapp/core/util/appcolors.dart';
import 'package:share_plus/share_plus.dart';

final selectedTabProvider = StateProvider<String>((ref) => 'description');

class JobDetailsScreen extends ConsumerWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final jobseekerState = ref.watch(jobseekerProvider);
    final jobseekerInfo = jobseekerState.jobseekerInfo;
    final Colorscheme = Theme.of(context).colorScheme;
    log('Jobseeker Info: $jobseekerInfo');
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.faintbackblue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: AppColors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: width * 0.02),
            child: Container(
              height: height * 0.05,
              width: width * 0.11,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: AppColors.darkGrey.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    color: AppColors.black,
                    size: 18,
                  ),
                  onPressed: () {
                    try {
                      _shareJobDetails(job);
                    } catch (e) {
                      log('Share error: $e');
                      _showSnackBar(
                        context: context,
                        text: 'Failed to share',
                        textColor: Colorscheme.error,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
        title: Text(
          'Job Details',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Header Section
            _buildCompanyHeader(height, width, job),
            SizedBox(height: height * 0.015),
            // Job Tags Section - Updated to use actual data
            _buildJobTagsSection(job, width, height),
            SizedBox(height: height * 0.02),
            selectinfocontainer(context, width, height, ref),
            SizedBox(height: height * 0.01),
            SizedBox(height: height * 0.02),
            // Job Description - Updated to use actual data
            _buildDescriptionSection(job, height, width),
            SizedBox(height: 20),

            // Requirements - Updated to use actual data
            _buildRequirementsSection(job, height, width),
            SizedBox(height: 20),

            // Benefits - Updated to use actual data
            _buildBenefitsSection(job, height, width),
            SizedBox(height: 30),

            // Apply Button
            _buildApplyButton(context, ref, job, height, width, Colorscheme),
            SizedBox(height: height * 0.1),
          ],
        ),
      ),
    );
  }

  void _shareJobDetails(JobModel job) {
    // Build requirements list
    final requirements = job.requirements.isNotEmpty
        ? job.requirements.split(',').map((req) => '• ${req.trim()}').join('\n')
        : '• Good communication skills\n• Relevant experience\n• Positive attitude';

    // Build benefits list
    final benefits = job.benefits.isNotEmpty
        ? job.benefits
              .split('.')
              .map((benefit) => '• ${benefit.trim()}')
              .join('\n')
        : '• Competitive salary\n• Growth opportunities\n• Friendly work environment';

    final shareText =
        '''
🌟 *JOB OPPORTUNITY ALERT* 🌟

*Position:* ${job.designation.isNotEmpty ? job.designation : 'Multiple Positions'}
*Company:* ${job.companyName.isNotEmpty ? job.companyName : 'Reputed Company'}
*Location:* ${job.location.isNotEmpty ? job.location : 'Multiple Locations'}

*Job Details:*
💼 Type: ${job.jobType.isNotEmpty ? job.jobType : 'Full-time'}
💰 Package: ${job.ctc.isNotEmpty ? job.ctc : 'Competitive Salary'}
🎯 Experience: ${job.experience.isNotEmpty ? job.experience : '0-5 years'}
👥 Age: ${job.ageRange.isNotEmpty ? job.ageRange : '18-35 years'}

*Job Description:*
${job.application.isNotEmpty ? job.application : 'Exciting opportunity with growth potential in a dynamic environment.'}

*Requirements:*
$requirements

*Benefits:*
$benefits

${job.isUrgentHiring ? '🚨 *URGENT HIRING - IMMEDIATE JOINING* 🚨' : ''}

Interested candidates can apply now!
📧 Share with someone who might be interested!

#JobOpportunity #Hiring #CareerGrowth
  ''';

    // ignore: deprecated_member_use
    Share.share(
      shareText,
      subject: 'Job: ${job.designation} at ${job.companyName}',
    );
  }

  Widget _buildCompanyHeader(double height, double width, JobModel job) {
    return Container(
      padding: EdgeInsets.all(width * 0.018),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: width * 0.14,
            height: height * 0.06,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColors.grey),
            ),
            child: Padding(
              padding: EdgeInsets.all(width * 0.006),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  job.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.business, color: AppColors.grey),
                ),
              ),
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: width * 0.6,
                        child: Text(
                          job.designation.isNotEmpty
                              ? job.designation
                              : 'Designation not specified',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: height * 0.005),
                      Row(
                        children: [
                          SizedBox(
                            width: width * 0.4,
                            child: Text(
                              job.companyName.isNotEmpty
                                  ? job.companyName
                                  : 'Company not specified',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: width * 0.01),
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.black,
                          ),
                          SizedBox(width: width * 0.005),
                          SizedBox(
                            width: width * 0.2,
                            child: Text(
                              job.location.isNotEmpty
                                  ? job.location
                                  : 'Location not specified',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 10,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Updated Job Tags Section to use actual data
  Widget _buildJobTagsSection(JobModel job, double width, double height) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Job Type
        if (job.jobType.isNotEmpty) jdcontainer(job.jobType, width, height),
        // Location
        jdcontainer(
          job.location.isNotEmpty ? job.location : 'Location not specified',
          width,
          height,
        ),

        // Experience
        if (job.experience.isNotEmpty)
          jdcontainer(job.experience, width, height),

        // Age Range
        if (job.ageRange.isNotEmpty) jdcontainer(job.ageRange, width, height),

        // CTC
        if (job.ctc.isNotEmpty) jdcontainer('${job.ctc} CTC', width, height),

        // Urgent Hiring Badge
        if (job.isUrgentHiring)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(10),
              // ignore: deprecated_member_use
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flash_on, size: 10, color: Colors.red),
                SizedBox(width: 4),
                Text(
                  'Urgent Hiring',
                  style: TextStyle(
                    fontSize: 08,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget jdcontainer(String text, double width, double height) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.lightblue.withValues(alpha: 0.3),
        // ignore: deprecated_member_use
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 08,
          color: AppColors.black,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget selectinfocontainer(
    BuildContext context,
    double width,
    double height,
    WidgetRef ref,
  ) {
    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
        // ignore: deprecated_member_use
        color: AppColors.verylightblue.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          singleinfocontainer(width, height, 'description', ref),
          singleinfocontainer(width, height, 'Company', ref),
          singleinfocontainer(width, height, 'Reviews', ref),
        ],
      ),
    );
  }

  Widget singleinfocontainer(
    double width,
    double height,
    String text,
    WidgetRef ref,
  ) {
    final selectedTab = ref.watch(selectedTabProvider);
    final isSelected = selectedTab == text;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(selectedTabProvider.notifier).state = text;
        },
        child: Container(
          height: height * 0.04,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: isSelected
                ? AppColors.black
                : AppColors.verylightblue.withValues(alpha: 0.1),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppColors.white : AppColors.black,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Updated Description Section to use actual data
  Widget _buildDescriptionSection(JobModel job, double height, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: height * 0.015),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppColors.verylightblue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            // ignore: deprecated_member_use
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
          ),
          child: Text(
            job.application.isNotEmpty
                ? job.application
                : 'No job description provided. This position offers great opportunities for growth and development in a dynamic work environment.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              // ignore: deprecated_member_use
              color: AppColors.grey,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // Updated Requirements Section to use actual data
  Widget _buildRequirementsSection(JobModel job, double height, double width) {
    final requirements = job.requirements.isNotEmpty
        ? job.requirements
              .split(',')
              .where((req) => req.trim().isNotEmpty)
              .toList()
        : [
            '10+2 (Higher Secondary) or equivalent',
            'Fluent in English (and sometimes Hindi or local language)',
            'Age between ${job.ageRange.isNotEmpty ? job.ageRange : "18-30"} years',
            'Minimum ${job.experience.isNotEmpty ? job.experience : "0-1 years"} experience',
            'Medically fit with no visible tattoos/scars',
            'Normal or corrected to normal vision',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requirements',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: height * 0.015),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppColors.verylightblue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            // ignore: deprecated_member_use
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              ...requirements.map(
                (requirement) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          requirement.trim(),
                          style: TextStyle(
                            color: AppColors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Updated Benefits Section to use actual data
  Widget _buildBenefitsSection(JobModel job, double height, double width) {
    final benefits = job.benefits.isNotEmpty
        ? job.benefits
              .split('.')
              .where((benefit) => benefit.trim().isNotEmpty)
              .toList()
        : [
            'Competitive salary package',
            'Health insurance coverage',
            'Travel allowances and benefits',
            'Professional development opportunities',
            'Flexible work environment',
            'Performance-based incentives',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benefits',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: height * 0.015),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppColors.verylightblue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            // ignore: deprecated_member_use
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              ...benefits.map(
                (benefit) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        size: 16,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit.trim(),
                          style: TextStyle(
                            color: AppColors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // List<Widget> _buildBulletPoints(String text) {
  //   final points = text.split('\n').where((point) => point.trim().isNotEmpty);

  //   if (points.isEmpty) {
  //     return [
  //       Text('No information available', style: TextStyle(color: AppColors.grey)),
  //     ];
  //   }
  //   return points
  //       .map(
  //         (point) => Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 4),
  //           child: Row(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 '• ',
  //                 style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
  //               ),
  //               Expanded(
  //                 child: Text(
  //                   point.trim(),
  //                   style: TextStyle(
  //                     color: AppColors.grey,
  //                     fontWeight: FontWeight.w400,
  //                     fontSize: 09,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       )
  //       .toList();
  // }

  Widget _buildApplyButton(
    BuildContext context,
    WidgetRef ref,
    JobModel job,
    double height,
    double width,
    ColorScheme colorscheme,
  ) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          _showApplyDialog(context, job, height, width, ref, colorscheme);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              // ignore: deprecated_member_use
              color: AppColors.black.withValues(alpha: 0.2),
              width: 1.5,
            ),
            gradient: LinearGradient(
              colors: [AppColors.faintbackblue, AppColors.white],
              // colors: job.isUrgentHiring
              //   ? [Colors.red, Colors.orange] // Urgent hiring gradient
              //   : [AppColors.lightBlue, AppColors.faintbackblue], // Normal gradient
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.0, 1.0], // Smooth transition from left to right
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              // job.isUrgentHiring ? 'Apply Now' : 'Apply Now
              'Apply Now',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showApplyDialog(
    BuildContext context,
    JobModel job,
    double height,
    double width,
    WidgetRef ref,
    ColorScheme colorscheme,
  ) {
    final jobseekerState = ref.read(jobseekerProvider);
    final jobseekerInfo = jobseekerState.jobseekerInfo;
    log(job.id);

    // Check if jobseeker has complete profile and resume
    final hasCompleteProfile =
        jobseekerInfo != null &&
        jobseekerInfo.name.isNotEmpty &&
        jobseekerInfo.resumeUrl.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Apply for ${job.designation}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        content: hasCompleteProfile
            ? Text(
                job.isUrgentHiring
                    ? 'This is an urgent hiring position! Apply now to get priority consideration for ${job.designation} at ${job.companyName}.'
                    : 'Are you sure you want to apply for ${job.designation} at ${job.companyName}?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete your profile to apply:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (jobseekerInfo == null || jobseekerInfo.name.isEmpty)
                    Text(
                      '• Add your personal information',
                      style: TextStyle(fontSize: 10),
                    ),
                  if (jobseekerInfo?.resumeUrl.isEmpty ?? true)
                    Text(
                      '• Upload your resume',
                      style: TextStyle(fontSize: 10),
                    ),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          if (hasCompleteProfile)
            ElevatedButton(
              onPressed: () => _submitApplication(
                context,
                job,
                jobseekerInfo,
                ref,
                colorscheme,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: job.isUrgentHiring
                    ? Colors.red
                    : AppColors.lightBlue,
              ),
              child: Text(
                job.isUrgentHiring ? 'Apply Urgently' : 'Apply',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to profile completion screen
                _navigateToProfile(context, colorscheme);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.grey),
              child: Text(
                'Complete Profile',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _submitApplication(
    BuildContext context,
    JobModel job,
    JobseekerModel jobseekerInfo,
    WidgetRef ref,
    ColorScheme colorscheme,
  ) async {
    try {
      final isUpdating = ref.read(applicationUpdateProvider);
      if (isUpdating) return; // Prevent multiple clicks

      // Check if already applied
      final repository = ref.read(jobRepositoryProvider);
      final hasApplied = await repository.hasAppliedForJob(
        jobseekerInfo.email,
        job.id,
        job.recruiterEmail,
      );

      if (hasApplied) {
        _showSnackBar(
          // ignore: use_build_context_synchronously
          context: context,
          text: 'You have already applied for this position!',
          textColor: colorscheme.tertiary,
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        return;
      }

      // Submit application using provider
      await ref
          .read(applicationUpdateProvider.notifier)
          .applyForJob(
            job: job,
            jobseekerInfo: jobseekerInfo,
            coverLetter: '', // Add cover letter if needed
          );

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      _showSnackBar(
        // ignore: use_build_context_synchronously
        context: context,
        text: 'Application submitted successfully!',
        textColor: colorscheme.tertiaryFixed,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      _showSnackBar(
        // ignore: use_build_context_synchronously
        context: context,
        text: 'Failed to submit application: $e',
        textColor: colorscheme.error,
      );
    }
  }

  void _navigateToProfile(BuildContext context, ColorScheme colorscheme) {
    _showSnackBar(
      context: context,
      text: 'Please complete your profile and upload resume',
      textColor: colorscheme.tertiary,
    );
  }

  // String _calculateTimeAgo(DateTime? postedDate) {
  //   if (postedDate == null) return 'Recently';

  //   final difference = DateTime.now().difference(postedDate);
  //   if (difference.inMinutes < 60) {
  //     return '${difference.inMinutes} min ago';
  //   } else if (difference.inHours < 24) {
  //     return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  //   } else {
  //     return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  //   }
  // }
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
