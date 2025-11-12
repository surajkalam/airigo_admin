// profile_information_screen.dart
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/JobSeeker/jobseekers_screens/editcandidateinfo_screen.dart';
import 'package:jobapp/Feature/combomodel/resumeview_screen.dart';

import 'package:jobapp/Feature/JobSeeker/modelclass/jobseeker_info.dart';
import 'package:jobapp/Feature/JobSeeker/provider/jobseeker_provider.dart';

import '../service.dart/pdf_uploadservice.dart' show pdfUploadServiceProvider;

class ProfileInformationScreen extends ConsumerStatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  ConsumerState<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState
    extends ConsumerState<ProfileInformationScreen> {
  @override
  Widget build(BuildContext context) {
    // Safely access theme colors with fallbacks
    ColorScheme? colorScheme;
    try {
      colorScheme = Theme.of(context).colorScheme;
    } catch (e) {
      // Fallback to default colors if theme is not available
      colorScheme = ColorScheme.light();
    }

    log('Building ProfileInformationScreen');
    final jobseekerState = ref.watch(jobseekerProvider);
    final jobseekerInfo = jobseekerState.jobseekerInfo;
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile Information',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          // Add Edit Button in AppBar
          IconButton(
            icon: Icon(Icons.edit, color: colorScheme.primary),
            onPressed: () {
              _showEditBottomSheet(jobseekerInfo!);
            },
          ),
        ],
      ),
      body: jobseekerState.isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : jobseekerInfo == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Profile Information',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: height * 0.009),
                  Text(
                    'Please complete your profile',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Personal Information Card
                  _buildInfoCard(
                    title: 'Personal Information',
                    icon: Icons.person_outline,
                    children: [
                      _buildInfoRow(
                        'Full Name :',
                        jobseekerInfo.name,
                        height,
                        width,
                        colorScheme,
                      ),
                      _buildInfoRow(
                        'Email :',
                        jobseekerInfo.email,
                        height,
                        width,
                        colorScheme,
                      ),
                      _buildInfoRow(
                        'Contact :',
                        jobseekerInfo.contact,
                        height,
                        width,
                        colorScheme,
                      ),
                      _buildInfoRow(
                        'Date of Birth :',
                        jobseekerInfo.dateOfBirth,
                        height,
                        width,
                        colorScheme,
                      ),
                      _buildInfoRow(
                        'Age :',
                        '${jobseekerInfo.age} years',
                        height,
                        width,
                        colorScheme,
                      ),
                    ],
                    context: context,
                    height: height,
                    width: width,
                    colorScheme: colorScheme,
                  ),
                  SizedBox(height: 16),
                  // Professional Information Card
                  _buildInfoCard(
                    title: 'Professional Information',
                    icon: Icons.work_outline,
                    children: [
                      _buildInfoRow(
                        'Job Designation :',
                        jobseekerInfo.jobDesignation,
                        height,
                        width,
                        colorScheme,
                      ),
                      _buildInfoRow(
                        'Qualification :',
                        jobseekerInfo.qualification,
                        height,
                        width,
                        colorScheme,
                      ),
                      _buildInfoRow(
                        'Experience :',
                        jobseekerInfo.experience,
                        height,
                        width,
                        colorScheme,
                      ),
                      _buildInfoRow(
                        'Location :',
                        jobseekerInfo.location,
                        height,
                        width,
                        colorScheme,
                      ),
                    ],
                    context: context,
                    height: height,
                    width: width,
                    colorScheme: colorScheme,
                  ),
                  SizedBox(height: 16),
                  // Resume Information Card
                  _buildInfoCard(
                    title: 'Resume ',
                    icon: Icons.description_outlined,
                    children: [
                      if (jobseekerInfo.resumeUrl.isNotEmpty)
                        _buildResumeSection(
                          jobseekerInfo,
                          context,
                          height,
                          width,
                          colorScheme,
                        )
                      else
                        _buildInfoRow(
                          'Resume',
                          'Not uploaded',
                          height,
                          width,
                          colorScheme,
                        ),
                    ],
                    context: context,
                    height: height,
                    width: width,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required BuildContext context,
    required double height,
    required double width,
    required ColorScheme colorScheme,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        color: colorScheme.surface,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                SizedBox(width: width * 0.025),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.015),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    double height,
    double width,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.009),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeSection(
    JobseekerModel jobseekerInfo,
    BuildContext context,
    double height,
    double width,
    ColorScheme colorScheme,
  ) {
    final hasResume = jobseekerInfo.resumeUrl.isNotEmpty;
    return Column(
      children: [
        _buildInfoRow(
          'Resume File',
          hasResume ? jobseekerInfo.resumeFileName : 'No resume uploaded',
          height,
          width,
          colorScheme,
        ),
        SizedBox(height: 8),
        // Resume Actions Row
        Row(
          children: [
            // View/Upload Resume Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: hasResume
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResumeViewerScreen(
                              resumeUrl: jobseekerInfo.resumeUrl,
                              resumeFileName: jobseekerInfo.resumeFileName,
                            ),
                          ),
                        );
                      }
                    : _uploadResumeWithProvider, // Use provider method for upload
                icon: Icon(
                  hasResume ? Icons.visibility_outlined : Icons.upload,
                  size: 16,
                  color: colorScheme.onSurface,
                ),
                label: Text(
                  hasResume
                      // ? 'View ${jobseekerInfo.resumeFileName}'
                      ? 'View'
                      : 'Upload Resume',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.primary,
                  // ignore: deprecated_member_use
                  side: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.6),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            // Edit and Delete Buttons (only show if resume exists)
            if (hasResume) ...[
              SizedBox(width: 8),
              // Edit Button
              SizedBox(
                width: 40,
                height: 40,
                child: ElevatedButton(
                  onPressed:
                      _uploadResumeWithProvider, // Use provider method for edit
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
              SizedBox(width: 4),

              // Delete Button
              SizedBox(
                width: 40,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    _showDeleteResumeDialog(jobseekerInfo);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: colorScheme.onError,
                  ),
                ),
              ),
            ],
          ],
        ),

        // Show resume URL if exists
        // if (hasResume)
        //   Padding(
        //     padding: EdgeInsets.only(top: 4),
        //     child: Text(
        //       'Resume URL: ${jobseekerInfo.resumeUrl}',
        //       style: TextStyle(fontSize: 9, color: Colors.blue),
        //       overflow: TextOverflow.ellipsis,
        //     ),
        //   ),
      ],
    );
  }

  Future<void> _uploadResumeWithProvider() async {
    // Safely access theme colors with fallbacks
    ColorScheme? colorScheme;
    try {
      colorScheme = Theme.of(context).colorScheme;
    } catch (e) {
      // Fallback to default colors if theme is not available
      colorScheme = ColorScheme.light();
    }

    try {
      final pdfService = ref.read(pdfUploadServiceProvider);

      // Pick PDF file using your existing service
      final File? pdfFile = await pdfService.pickPdf();
      if (pdfFile == null) return;
      // ignore: use_build_context_synchronously
      _showSnackBar(
        context: context,
        text: 'Uploading resume...',
        backgroundColor: colorScheme.surface,
        textColor: colorScheme.primary,
      );
      await ref.read(jobseekerProvider.notifier).uploadResume(pdfFile);
      // ignore: use_build_context_synchronously
      _showSnackBar(
        context: context,
        text: 'Resume uploaded successfully!',
        backgroundColor: colorScheme.surface,
        textColor: Colors.green,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload resume: $e'),
          backgroundColor: colorScheme.error,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showDeleteResumeDialog(JobseekerModel jobseekerInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Resume',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete your resume "${jobseekerInfo.resumeFileName}"? This action cannot be undone.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 14)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteResume();
            },
            child: Text(
              'Delete',
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteResume() async {
    // Safely access theme colors with fallbacks
    ColorScheme? colorScheme;
    try {
      colorScheme = Theme.of(context).colorScheme;
    } catch (e) {
      // Fallback to default colors if theme is not available
      colorScheme = ColorScheme.light();
    }

    try {
      await ref.read(jobseekerProvider.notifier).deleteResume();
      // ignore: use_build_context_synchronously
      _showSnackBar(
        context: context,
        text: 'Resume deleted successfully',
        backgroundColor: colorScheme.surface,
        textColor: Colors.green,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      _showSnackBar(
        // ignore: use_build_context_synchronously
        context: context,
        text: 'Failed to delete resume: $e',
        backgroundColor: colorScheme.surface,
        textColor: colorScheme.error,
      );
    }
  }

  void _showEditBottomSheet(JobseekerModel jobseekerInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileBottomSheet(
        jobseekerInfo: jobseekerInfo,
        onSave: (updatedInfo) async {
          try {
            await ref
                .read(jobseekerProvider.notifier)
                .updateJobseekerInfo(updatedInfo);
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
            _showSnackBar(
              context: context,
              text: 'Profile updated successfully!',
              backgroundColor: Theme.of(context).colorScheme.surface,
              textColor: Colors.green,
            );
          } catch (e) {
            _showSnackBar(
              context: context,
              text: 'Failed to update profile: $e',
              backgroundColor: Theme.of(context).colorScheme.surface,
              textColor: Colors.red,
            );
          }
        },
      ),
    );
  }

  void _showSnackBar({
    required BuildContext context,
    required String text,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.green,
    Duration duration = const Duration(seconds: 2),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: TextStyle(color: textColor)),
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
