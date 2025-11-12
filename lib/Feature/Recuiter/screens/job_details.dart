import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jobapp/Authentication/user_provider.dart';
import 'package:jobapp/Feature/combomodel/jobupload_model.dart';
import 'package:jobapp/core/util/image_pickerutil.dart';
import 'dart:io';
import '../provider/provider.dart';

class JobuploaddetailScreen extends ConsumerStatefulWidget {
  const JobuploaddetailScreen({super.key});
  @override
  ConsumerState<JobuploaddetailScreen> createState() => _JobdetailScreenState();
}

class _JobdetailScreenState extends ConsumerState<JobuploaddetailScreen> {
  int selectedIndex = 0;
  File? _selectedImage;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Controllers
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _ctcController = TextEditingController();
  final TextEditingController _noticePeriodController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _benefitsController = TextEditingController();
  final TextEditingController _qualificationsController =
      TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _ageRangeController = TextEditingController();

  String selectedExperience = '0-1 years';
  bool isUrgentHiring = false;

  // Experience options
  final List<String> experienceOptions = [
    '0-1 years',
    '1-2 years',
    '2-3 years',
    '3-5 years',
    '5-7 years',
    '7-10 years',
    '10+ years',
  ];
  String selectedJobType = 'Full-time';
  final List<String> jobTypeOptions = [
    'Full-time',
    'Part-time',
    'Internship',
    'Contract',
    'Remote',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _designationController.dispose();
    _ctcController.dispose();
    _noticePeriodController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _benefitsController.dispose();
    _qualificationsController.dispose();
    _skillsController.dispose();
    _requirementsController.dispose();
    _ageRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobState = ref.watch(jobNotifierProvider);
    return CustomScaffold(
      scaffoldKey: _scaffoldKey,
      child: _buildBody(context, jobState),
    );
  }

  Widget _buildBody(BuildContext context, JobState jobState) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.all(width * 0.022),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildCategorySelection(width, height, colorScheme, textTheme),
            _buildSelectedContainer(height, width, colorScheme, jobState),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection(
    double width,
    double height,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        _buildCategoryButton(
          height,
          width,
          'Airline',
          colorScheme,
          textTheme,
          1,
        ),
        _buildCategoryButton(
          height,
          width,
          'Hospitality',
          colorScheme,
          textTheme,
          2,
        ),
      ],
    );
  }

  Widget _buildCategoryButton(
    double height,
    double width,
    String text,
    ColorScheme colorScheme,
    TextTheme textTheme,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _handleCategorySelection(index),
      child: _buildChoiceContainer(
        height,
        width,
        text,
        colorScheme,
        textTheme,
        selectedIndex == index,
      ),
    );
  }

  void _handleCategorySelection(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget _buildSelectedContainer(
    double height,
    double width,
    ColorScheme colorscheme,
    JobState jobState,
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: _buildJobForm(height, width, colorscheme, jobState),
        ),
      ],
    );
  }

  Widget _buildJobForm(
    double height,
    double width,
    ColorScheme colorschem,
    JobState jobState,
  ) {
    return Column(
      children: [
        _buildImagePickerContainer(height, width),
        _buildTextFormField(
          height,
          width,
          _companyNameController,
          'Company Name *',
          icon: Icon(Iconsax.building, size: 18),
          isRequired: true,
        ),
        _buildTextFormField(
          height,
          width,
          _designationController,
          'Role/Designation *',
          icon: Icon(Iconsax.briefcase, size: 18),
          isRequired: true,
        ),
        _buildTextFormField(
          height,
          width,
          _ctcController,
          'CTC *',
          icon: Icon(Iconsax.wallet, size: 18),
          isRequired: true,
          isNumber: false,
        ),
        _buildTextFormField(
          height,
          width,
          _noticePeriodController,
          'Notice Period *',
          icon: Icon(Iconsax.calendar, size: 18),
          isRequired: true,
        ),
        _buildTextFormField(
          height,
          width,
          _locationController,
          'Location *',
          icon: Icon(Iconsax.location, size: 18),
          isRequired: true,
        ),
        _buildJobTypeSelector(height, width),
        _buildTextFormField(
          height,
          width,
          _requirementsController,
          'Requirements (use commas to separate) *',
          icon: Icon(Iconsax.task, size: 18),
          isRequired: true,
          maxline: 3,
        ),
        _buildExperienceSelector(height, width),
        _buildTextFormField(
          height,
          width,
          _ageRangeController,
          'Age Range (e.g., 18-27, 20-30) *',
          icon: Icon(Iconsax.calendar_1, size: 18),
          isRequired: true,
        ),
        _buildTextFormField(
          height,
          width,
          _descriptionController,
          'Job Description *',
          icon: Icon(Iconsax.document_text, size: 18),
          isRequired: true,
          maxline: 3,
        ),
        _buildTextFormField(
          height,
          width,
          _benefitsController,
          'Benefits',
          icon: Icon(Iconsax.gift, size: 18),
          maxline: 3,
        ),
        _buildTextFormField(
          height,
          width,
          _qualificationsController,
          'Qualifications',
          icon: Icon(Iconsax.book, size: 18),
          maxline: 3,
        ),
        _buildTextFormField(
          height,
          width,
          _skillsController,
          'Required Skills',
          icon: Icon(Iconsax.code, size: 18),
          maxline: 3,
        ),
        _buildUrgentHiringToggle(height, width),
        SizedBox(height: height * 0.04),

        if (jobState.isLoading)
          CircularProgressIndicator()
        else
          _buildSubmitButton(height, width, colorschem, _handleSubmit),

        if (jobState.error != null)
          Padding(
            padding: EdgeInsets.only(top: height * 0.02),
            child: Text(
              'Error: ${jobState.error}',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        // if (jobState.success)
        //   Padding(
        //     padding: EdgeInsets.only(top: height * 0.02),
        //     child: Text(
        //       'Job posted successfully!',
        //       style: TextStyle(color: Colors.green, fontSize: 12),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildJobTypeSelector(double height, double width) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: height * 0.012,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Type *',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: height * 0.04,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: jobTypeOptions.length,
              itemBuilder: (context, index) {
                final jobType = jobTypeOptions[index];
                final isSelected = selectedJobType == jobType;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedJobType = jobType;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Color.fromRGBO(223, 226, 230, 1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        jobType,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSelector(double height, double width) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: height * 0.012,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experience Required *',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: height * 0.04,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: experienceOptions.length,
              itemBuilder: (context, index) {
                final experience = experienceOptions[index];
                final isSelected = selectedExperience == experience;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedExperience = experience;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Color.fromRGBO(223, 226, 230, 1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        experience,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentHiringToggle(double height, double width) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: height * 0.012,
      ),
      child: Row(
        children: [
          Icon(Iconsax.clock, size: 18, color: Colors.grey),
          SizedBox(width: 12),
          Text(
            'Urgent Hiring:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                isUrgentHiring = !isUrgentHiring;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 50,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isUrgentHiring ? Colors.green : Colors.grey[300],
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 200),
                    left: isUrgentHiring ? 22 : 2,
                    top: 2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            isUrgentHiring ? 'Yes' : 'No',
            style: TextStyle(
              fontSize: 12,
              color: isUrgentHiring ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerContainer(double height, double width) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: height * 0.15,
        width: width * 0.9,
        margin: EdgeInsets.symmetric(vertical: height * 0.02),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
          color: Color.fromRGBO(223, 226, 230, 1),
        ),
        child: _selectedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.camera, size: 32, color: Colors.grey),
                  SizedBox(height: 6),
                  Text(
                    'Tap to add company image *',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      File? image = await ImagePickerUtils.pickImageFromGallery();

      if (image != null) {
        bool fileExists = await image.exists();

        if (!fileExists) {
          // ignore: use_build_context_synchronously
          _showSnackBar(
            context: context,
            text: 'Selected image file is not accessible 👎',
            textColor: Colors.red,
          );
          return;
        }

        final fileLength = await image.length();
        if (fileLength > 10 * 1024 * 1024) {
          // ignore: use_build_context_synchronously
          _showSnackBar(
            context: context,
            text: 'Image file is too large. Please select a smaller image.',
            textColor: Colors.red,
          );
          return;
        }

        setState(() {
          _selectedImage = image;
        });

        // _showSnackBar('Image selected successfully');
        // ignore: use_build_context_synchronously
        _showSnackBar(
          context: context,
          text: 'Image selected successfully 👍',
          textColor: Colors.green,
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      _showSnackBar(
        context: context,
        text: 'Failed to pick image try again',
        textColor: Colors.red,
      );
      log('Image picking error: $e');
    }
  }

  Widget _buildTextFormField(
    double height,
    double width,
    TextEditingController controller,
    String label, {
    Icon? icon,
    int? maxline,
    bool isRequired = false,
    bool isNumber = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: height * 0.012,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxline ?? 1,
        style: TextStyle(fontSize: 12),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: icon,
          filled: true,
          fillColor: Color.fromRGBO(223, 226, 230, 1),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    double height,
    double width,
    ColorScheme colorscheme,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: width - 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: onPressed,
        child: Text(
          'Submit Job', // Always show "Submit Job" since we're only creating new jobs
          style: TextStyle(fontSize: 12, color: colorscheme.onSecondary),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    try {
      ref.read(jobNotifierProvider.notifier).clearError();
      ref.read(jobNotifierProvider.notifier).clearSuccess();

      // Validate required fields
      if (_selectedImage == null) {
        _showSnackBar(
          context: context,
          text: 'Please select a company image',
          textColor: Colors.red,
        );
        return;
      }

      if (_companyNameController.text.isEmpty ||
          _designationController.text.isEmpty ||
          _ctcController.text.isEmpty ||
          _noticePeriodController.text.isEmpty ||
          _locationController.text.isEmpty ||
          _descriptionController.text.isEmpty ||
          _requirementsController.text.isEmpty ||
          _ageRangeController.text.isEmpty) {
        _showSnackBar(
          context: context,
          text: 'Please fill all required fields',
          textColor: Colors.red,
        );
        return;
      }

      // Validate age range format
      if (!_isValidAgeRange(_ageRangeController.text)) {
        _showSnackBar(
          context: context,
          text: 'Please enter age range in format like 18-27 or 20-30',
          textColor: Colors.red,
        );
        return;
      }

      // Get category
      String category = selectedIndex == 1 ? 'Airline' : 'Hospitality';

      final jobNotifier = ref.read(jobNotifierProvider.notifier);
      final recruiterEmail = ref.read(currentRecruiterUserEmailProvider);

      // Upload image
      String imageUrl = await jobNotifier.uploadImage(_selectedImage!);
      String jobId = 'JOB_${DateTime.now().millisecondsSinceEpoch}';
      // Create job model
      JobModel jobData = JobModel(
        id: jobId,
        companyName: _companyNameController.text,
        designation: _designationController.text,
        ctc: _ctcController.text,
        noticePeriod: _noticePeriodController.text,
        location: _locationController.text,
        application: _descriptionController.text,
        imageUrl: imageUrl,
        category: category,
        createdAt: DateTime.now(),
        recruiterEmail: recruiterEmail,
        benefits: _benefitsController.text,
        qualifications: _qualificationsController.text,
        skills: _skillsController.text,
        requirements: _requirementsController.text,
        experience: selectedExperience,
        ageRange: _ageRangeController.text,
        isUrgentHiring: isUrgentHiring,
      );

      // Save job
      await jobNotifier.saveJob(jobData);

      // Check if successful
      final currentState = ref.read(jobNotifierProvider);
      if (currentState.success) {
        // _showSnackBar('$category Job posted successfully!');
        // ignore: use_build_context_synchronously
        _showSnackBar(
          context: context,
          text: '$category Job posted successfully!',
          textColor: Colors.green,
        );
        _clearForm(); // Clear form after successful submission
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      _showSnackBar(
        context: context,
        textColor: Colors.red,
        text: 'check all fields and try again',
      );
      log('Error submitting job: $e');
    }
  }

  bool _isValidAgeRange(String ageRange) {
    final regex = RegExp(r'^\d{2}-\d{2}$');
    if (!regex.hasMatch(ageRange)) return false;

    final parts = ageRange.split('-');
    final start = int.tryParse(parts[0]);
    final end = int.tryParse(parts[1]);

    if (start == null || end == null) return false;
    return start < end && start >= 18 && end <= 65;
  }

  void _clearForm() {
    _companyNameController.clear();
    _designationController.clear();
    _ctcController.clear();
    _noticePeriodController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _benefitsController.clear();
    _qualificationsController.clear();
    _skillsController.clear();
    _requirementsController.clear();
    _ageRangeController.clear();

    setState(() {
      _selectedImage = null;
      selectedExperience = '0-1 years';
      isUrgentHiring = false;
      selectedIndex = 0;
    });
    _showSnackBar(
      context: context,
      text: 'Form cleared. Ready for new job posting.',
      textColor: Colors.green,
    );
  }

  void _showSnackBar({
    required BuildContext context,
    required String text,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.green,
    Duration duration = const Duration(seconds: 3),
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

  Widget _buildChoiceContainer(
    double height,
    double width,
    String text,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isSelected,
  ) {
    return Padding(
      padding: EdgeInsets.all(width * 0.02),
      child: Container(
        height: height * 0.05,
        width: width * 0.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? colorScheme.primaryFixed : colorScheme.onPrimary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomScaffold extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget child;

  const CustomScaffold({
    super.key,
    required this.scaffoldKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Create New Job', style: TextStyle(fontSize: 14)),
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: colorScheme.onPrimary,
            size: 16,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: colorScheme.onSecondary,
      ),
      body: child,
    );
  }
}
