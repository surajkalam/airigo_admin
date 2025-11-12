// screens/contact_us_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/JobSeeker/jobseekers_screens/my_issues_screen.dart';
import 'package:jobapp/Feature/JobSeeker/provider/application_provider.dart';
import 'package:jobapp/Feature/JobSeeker/provider/jobseeker_provider.dart';

class ContactUsScreen extends ConsumerStatefulWidget {
  const ContactUsScreen({super.key});

  @override
  ConsumerState<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends ConsumerState<ContactUsScreen> {
  String _selectedType = 'issue';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitIssueReport(ColorScheme colorScheme) async {
    if (_formKey.currentState!.validate()) {
      final jobseekerState = ref.read(jobseekerProvider);
      final jobseekerInfo = jobseekerState.jobseekerInfo;

      if (jobseekerInfo == null) {
        _showSnackBar(
          context: context,
          text: 'please complete your profile first',
          textColor: colorScheme.tertiary,
        );
        return;
      }
      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
        final repository = ref.read(jobRepositoryProvider);
        await repository.submitIssueReport(
          jobseekerEmail: jobseekerInfo.email,
          jobseekerName: jobseekerInfo.name.isNotEmpty
              ? jobseekerInfo.name
              : jobseekerInfo.email,
          type: _selectedType,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
        );

        // Hide loading
        if (mounted) Navigator.of(context).pop();
        _showSnackBar(
          context: context,
          text:
              '${_selectedType == 'issue' ? 'Issue' : 'Report'} submitted successfully!',
          textColor: colorScheme.tertiaryFixed,
        );

        // Navigate back
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        // Hide loading
        if (mounted) Navigator.of(context).pop();
        _showSnackBar(
          context: context,
          text: 'Failed to submit',
          textColor: colorScheme.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    TextTheme texttheme = Theme.of(context).textTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Contact Us',
          style: texttheme.labelMedium?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontSize: 14,
          ),
        ),
        backgroundColor: colorScheme.primary.withValues(alpha: 0.7),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyIssuesScreen()),
              );
            },
            icon: Icon(
              Icons.report_gmailerrorred,
              size: 22,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              SizedBox(height: height * 0.01),
              // Type Selection
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text(
                        'Issue',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      selected: _selectedType == 'issue',
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = 'issue';
                        });
                      },
                    ),
                  ),
                  SizedBox(width: width * 0.01),
                  Expanded(
                    child: ChoiceChip(
                      label: Text(
                        'Report',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      selected: _selectedType == 'report',
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = 'report';
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.033),

              // Title Field
              TextFormField(
                controller: _titleController,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onPrimaryContainer,
                ),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  border: OutlineInputBorder(),
                  hintText: _selectedType == 'issue'
                      ? 'e.g., App not working properly'
                      : 'e.g., Report inappropriate content',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.023),
              TextFormField(
                controller: _descriptionController,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onPrimaryContainer,
                ),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  border: OutlineInputBorder(),
                  hintText: _selectedType == 'issue'
                      ? 'Describe the issue in detail...'
                      : 'Provide detailed information about your report...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.036),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _submitIssueReport(colorScheme),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: height * 0.02),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.surface,
                    ),
                  ),
                ),
              ),

              // Help Text
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What to include:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedType == 'issue'
                          ? '• Steps to reproduce the issue\n• What you expected to happen\n• Screenshots if possible'
                          : '• Specific details of the concern\n• Relevant usernames or content\n• Why you are reporting this',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
