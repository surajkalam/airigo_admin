import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/JobSeeker/modelclass/jobseeker_info.dart';
import 'package:jobapp/Feature/JobSeeker/service.dart/pdf_uploadservice.dart';

class EditProfileBottomSheet extends StatefulWidget {
  final JobseekerModel jobseekerInfo;
  final Function(JobseekerModel) onSave;

  const EditProfileBottomSheet({
    super.key,
    required this.jobseekerInfo,
    required this.onSave,
  });

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _qualificationController;
  late TextEditingController _jobDesignationController;
  late TextEditingController _locationController;
  late TextEditingController _experienceController;
  late TextEditingController _dateOfBirthController;

  bool _isUploadingResume = false;
  String? _resumeFileName;
  String? _resumeUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.jobseekerInfo.name);
    _contactController = TextEditingController(
      text: widget.jobseekerInfo.contact,
    );
    _qualificationController = TextEditingController(
      text: widget.jobseekerInfo.qualification,
    );
    _jobDesignationController = TextEditingController(
      text: widget.jobseekerInfo.jobDesignation,
    );
    _locationController = TextEditingController(
      text: widget.jobseekerInfo.location,
    );
    _experienceController = TextEditingController(
      text: widget.jobseekerInfo.experience,
    );
    _dateOfBirthController = TextEditingController(
      text: widget.jobseekerInfo.dateOfBirth,
    );

    // Initialize with existing resume data
    _resumeUrl = widget.jobseekerInfo.resumeUrl;
    _resumeFileName = widget.jobseekerInfo.resumeFileName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _qualificationController.dispose();
    _jobDesignationController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _uploadResume() async {
    final pdfService = ProviderContainer().read(pdfUploadServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;

    try {
      setState(() {
        _isUploadingResume = true;
      });

      // Pick PDF file
      final File? pdfFile = await pdfService.pickPdf();
      if (pdfFile == null) {
        setState(() {
          _isUploadingResume = false;
        });
        return;
      }
      // Show uploading snackbar
      _showSnackBar(
        context: context,
        text: 'Uploading resume...',
        textColor: colorScheme.tertiary,
      );
      // Upload to Firebase Storage using your existing service
      final downloadUrl = await pdfService.uploadPdf(
        pdfFile,
        widget.jobseekerInfo.email,
        _nameController.text.trim(),
      );

      // Get file name
      final fileName = pdfService.getFileNameFromPath(pdfFile.path);

      setState(() {
        _resumeUrl = downloadUrl;
        _resumeFileName = fileName;
        _isUploadingResume = false;
      });
      _showSnackBar(
        context: context,
        text: 'Resume uploaded successfully!',
        textColor: colorScheme.tertiaryFixed,
      );
    } catch (e) {
      setState(() {
        _isUploadingResume = false;
      });

      _showSnackBar(
        context: context,
        text: 'Failed to upload resume try again !',
        textColor: colorScheme.error,
      );
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedInfo = widget.jobseekerInfo.copyWith(
        name: _nameController.text.trim(),
        contact: _contactController.text.trim(),
        qualification: _qualificationController.text.trim(),
        jobDesignation: _jobDesignationController.text.trim(),
        location: _locationController.text.trim(),
        experience: _experienceController.text.trim(),
        dateOfBirth: _dateOfBirthController.text.trim(),
        resumeUrl: _resumeUrl ?? widget.jobseekerInfo.resumeUrl,
        resumeFileName: _resumeFileName ?? widget.jobseekerInfo.resumeFileName,
      );
      widget.onSave(updatedInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    var height = MediaQuery.of(context).size.height;
    // var width = MediaQuery.of(context).size.width;

    return Container(
      height: height * 0.9,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurface,
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Form
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hintText: 'Enter your full name',
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      controller: _contactController,
                      label: 'Contact Number',
                      hintText: 'Enter your contact number',
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      controller: _qualificationController,
                      label: 'Qualification',
                      hintText: 'Enter your qualification',
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      controller: _jobDesignationController,
                      label: 'Job Designation',
                      hintText: 'Enter your job designation',
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      controller: _locationController,
                      label: 'Location',
                      hintText: 'Enter your location',
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      controller: _experienceController,
                      label: 'Experience',
                      hintText: 'Enter your experience',
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      controller: _dateOfBirthController,
                      label: 'Date of Birth (DD/MM/YYYY)',
                      hintText: 'Enter your date of birth',
                      colorScheme: colorScheme,
                    ),

                    // Resume Upload Section
                    SizedBox(height: 20),
                    _buildResumeSection(colorScheme),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4),
        TextFormField(
          controller: controller,
          style: TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildResumeSection(ColorScheme colorScheme) {
    final hasResume = _resumeUrl != null && _resumeUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resume',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8),

        if (hasResume)
          // Show resume info when uploaded
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(8),
              color: Colors.green.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                Icon(Icons.description, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _resumeFileName ?? 'Resume',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Resume uploaded successfully',
                        style: TextStyle(fontSize: 10, color: Colors.green),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.upload, color: colorScheme.primary),
                  onPressed: _uploadResume,
                  tooltip: 'Upload New Resume',
                ),
              ],
            ),
          )
        else
          // Show upload button when no resume
          OutlinedButton(
            onPressed: _isUploadingResume ? null : _uploadResume,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              backgroundColor: colorScheme.surface,
              // side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
            child: _isUploadingResume
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Uploading...',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Upload Resume',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
          ),
      ],
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
