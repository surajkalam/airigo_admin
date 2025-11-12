import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobapp/Authentication/user_provider.dart';
import 'package:jobapp/Feature/Recuiter/provider/provider.dart';

import '../recuiter_model/recuiter_model.dart';
import 'package:jobapp/core/services/local_storage_service.dart';
import 'package:jobapp/Authentication/auth_state.dart'; // Added import

class RecuiterInfo extends ConsumerStatefulWidget {
  final String email;
  final String phone;
  final String password;
  const RecuiterInfo({
    super.key,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  ConsumerState<RecuiterInfo> createState() => _RecuiterInfoState();
}

class _RecuiterInfoState extends ConsumerState<RecuiterInfo> {
  // final TextEditingController contactController = widget.phone != null ? TextEditingController(text: widget.phone) : TextEditingController();
  // final TextEditingController emailController = widget.email != null ? TextEditingController(text: widget.email) : TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController photoController = TextEditingController();

  File? _selectedImage;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isImageUploading = false; // Add this flag

  // Store signup data passed from previous screen
  String _signupEmail = '';
  String _signupPassword = '';
  String _signupPhone = '';

  @override
  void initState() {
    super.initState();
    // Pre-fill email and phone passed from constructor
    emailController.text = widget.email;
    contactController.text = widget.phone;
    _signupPassword = widget.password;
    // Pre-fill email and phone from local storage
    _loadSignupData();
  }

  Future<void> _loadSignupData() async {
    // Get signup data passed from the previous screen
    final extraData = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extraData != null) {
      _signupEmail = extraData['email'] ?? '';
      _signupPassword =
          extraData['password'] ??
          _signupPassword; // Use constructor password if extra data doesn't have it
      _signupPhone = extraData['phone'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    log('welcome in RecuiterInfo fill form');
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isLoading = ref.watch(loadingStateProvider);
    // final recruiterState = ref.watch(recruiterDataProvider);
    // final currentuseremail=ref.watch(currentUserEmailProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            colorScheme.surface, // Changed from AppColors.faintbackblue
        title: Text(
          "Recruiter information",
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme
                .onSurface, // Changed from colorScheme.primaryFixedDim
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: height * 0.01,
            horizontal: width * 0.01,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                textformfield(
                  height,
                  width,
                  nameController,
                  'full name',
                  icon: const Icon(Icons.person_2_outlined),
                  isRequired: true,
                ),
                textformfield(
                  height,
                  width,
                  emailController,
                  'E-mail',
                  icon: const Icon(Icons.mail_outline),
                  isRequired: true,
                  isEmail: true,
                ),
                textformfield(
                  height,
                  width,
                  contactController,
                  'Contact',
                  icon: const Icon(Icons.call),
                  isRequired: true,
                  isPhone: true,
                ),
                textformfield(
                  height,
                  width,
                  companyController,
                  'Company Name',
                  icon: const Icon(Icons.business),
                  isRequired: true,
                ),
                textformfield(
                  height,
                  width,
                  designationController,
                  'Designation/Skills',
                  icon: const Icon(Icons.domain),
                  isRequired: true,
                ),
                textformfield(
                  height,
                  width,
                  locationController,
                  'Location',
                  icon: const Icon(Icons.location_pin),
                  maxline: 3,
                  isRequired: true,
                ),

                // Modified ImagePickerFormField to handle file selection
                _buildImagePickerSection(height, width, colorScheme),
                SizedBox(height: height * 0.03),

                // Loading indicator and submit button
                if (isLoading ||
                    _isImageUploading) // Show loading when either is happening
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: width * 0.03,
                        horizontal: height * 0.09,
                      ),
                      backgroundColor: colorScheme
                          .tertiary, // Changed from colorScheme.secondaryFixed
                      foregroundColor:
                          colorScheme.onTertiary, // Added foreground color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _submitForm(colorScheme);
                    },
                    child: const Text("Submit"),
                  ),

                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerSection(
    double height,
    double width,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: height * 0.02,
        horizontal: width * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Photo *',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme
                  .onSurfaceVariant, // Changed from AppColors.black.withValues(alpha: 0.6)
            ),
          ),
          SizedBox(height: height * 0.01),
          Container(
            height: height * 0.15,
            width: width * 0.3,
            decoration: BoxDecoration(
              color: colorScheme.surface, // Changed from AppColors.white
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme
                    .outline, // Changed from AppColors.grey.withValues(alpha: 0.5)
              ),
            ),
            child: _selectedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.add_a_photo_outlined,
                          color: colorScheme
                              .onSurfaceVariant, // Changed from AppColors.grey.withValues(alpha: 0.7)
                        ),
                        onPressed: _showImageSourceDialog,
                      ),
                      Text(
                        'Upload Photo',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ), // Changed from AppColors.black.withValues(alpha: 0.6)
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 15,
                              color: Colors.white,
                            ),
                            onPressed: _clearImage,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          if (_selectedImage != null)
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Selected: ${_selectedImage!.path.split('/').last}',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme
                      .onSurfaceVariant, // Changed from AppColors.grey
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          context: context,
          text: 'Error picking image: ${_getErrorMessage(e)}',
          textColor: Colors.red,
        );
      }
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _submitForm(ColorScheme colorscheme) async {
    if (_formKey.currentState!.validate()) {
      try {
        // First, perform Firebase authentication
        final authNotifier = ref.read(authStateProvider.notifier);
        final user = await authNotifier.signUpWithEmailAndPassword(
          email: _signupEmail.isNotEmpty
              ? _signupEmail
              : emailController.text.trim(),
          password: _signupPassword,
          phoneNumber: _signupPhone.isNotEmpty
              ? _signupPhone
              : contactController.text,
        );

        if (user == null) {
          // Authentication failed
          final error = ref.read(authStateProvider).error;
          if (error != null && mounted) {
            _showSnackBar(
              context: context,
              text: error,
              textColor: colorscheme.error,
            );
          }
          return;
        }

        // Update the current user provider with the authenticated user's email
        ref.read(currentRecruiterUserEmailProvider.notifier).state =
            user.email ?? '';

        // Save user phone to local storage
        await LocalStorageService().setUserPhone(
          _signupPhone.isNotEmpty ? _signupPhone : contactController.text,
        );

        // Upload image if selected (only during submission)
        String photoUrl = '';
        if (_selectedImage != null) {
          setState(() {
            _isImageUploading = true;
          });

          try {
            final email = _signupEmail.isNotEmpty
                ? _signupEmail
                : emailController.text.trim();
            if (email.isEmpty) {
              throw Exception('Email is required to upload image');
            }

            final recruiterService = ref.read(firebaseRecruiterServiceProvider);
            photoUrl = await recruiterService.uploadImage(
              _selectedImage!,
              email,
            );
          } catch (e) {
            if (mounted) {
              _showSnackBar(
                context: context,
                text: 'Failed to upload image  ${_getErrorMessage(e)}',
                textColor: Colors.red,
              );
            }
            // Continue with submission even if image upload fails
          } finally {
            setState(() {
              _isImageUploading = false;
            });
          }
        }

        // Create RecruiterModel object
        final recruiterInfo = RecruiterModel(
          id: 'REC_${DateTime.now().millisecondsSinceEpoch}',
          name: nameController.text,
          email: emailController.text,
          contact: contactController.text,
          companyName: companyController.text,
          designation: designationController.text,
          location: locationController.text,
          photoUrl: photoUrl, // Use the uploaded image URL or empty string
          createdAt: DateTime.now(),
        );

        // Save recruiter info
        await ref
            .read(recruiterDataProvider.notifier)
            .saveRecruiter(recruiterInfo);

        if (mounted) {
          _showSnackBar(
            context: context,
            text: '✅ Profile submitted successfully!',
            textColor: colorscheme.tertiaryFixed,
          );
          // Navigate to recruiter home after successful submission
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/recuiter-nav');
          });
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar(
            context: context,
            text: 'Failed to submit profile try again',
            textColor: colorscheme.error,
          );
        }
      }
    }
  }

  // Helper function to create text form fields
  Widget textformfield(
    double height,
    double width,
    TextEditingController controller,
    String hinttext, {
    Widget? icon,
    bool isRequired = false,
    bool isEmail = false,
    bool isPhone = false,
    int maxline = 1,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    // final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: height * 0.02,
        horizontal: width * 0.02,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxline,
        keyboardType: isPhone
            ? TextInputType.phone
            : isEmail
            ? TextInputType.emailAddress
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: isRequired ? '$hinttext *' : hinttext,
          labelStyle: TextStyle(
            fontSize: 11,
            color: colorScheme
                .onSurfaceVariant, // Changed from AppColors.black.withValues(alpha: 0.6)
          ),
          hintText: 'Enter $hinttext',
          hintStyle: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant.withValues(
              alpha: 0.6,
            ), // Changed from AppColors.black.withValues(alpha: 0.6)
          ),
          filled: true,
          fillColor: colorScheme.surface, // Changed from AppColors.white
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme
                  .outline, // Changed from AppColors.grey.withValues(alpha: 0.5)
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme
                  .outline, // Changed from AppColors.grey.withValues(alpha: 0.5)
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme
                  .primary, // Changed from AppColors.grey.withValues(alpha: 0.8)
            ),
          ),
          prefixIcon: icon != null
              ? IconTheme.merge(
                  data: IconThemeData(
                    color: colorScheme.onSurfaceVariant,
                  ), // Changed from AppColors.grey.withValues(alpha: 0.7)
                  child: icon,
                )
              : null,
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Please enter $hinttext';
          }
          if (isEmail && value != null && value.isNotEmpty) {
            final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
            if (!emailRegex.hasMatch(value)) {
              return 'Please enter a valid email';
            }
          }
          if (isPhone && value != null && value.isNotEmpty) {
            if (value.length != 10) {
              return 'Please enter a valid 10-digit phone number';
            }
          }
          return null;
        },
      ),
    );
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('permission-denied') ||
        errorString.contains('access-denied')) {
      return 'Permission denied. Please check your file access permissions';
    } else if (errorString.contains('file-not-found') ||
        errorString.contains('path-not-found')) {
      return 'File not found. Please select a valid file';
    } else if (errorString.contains('file-too-large') ||
        errorString.contains('size-limit')) {
      return 'File is too large. Please choose a smaller file';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your internet connection';
    } else if (errorString.contains('invalid-format') ||
        errorString.contains('unsupported')) {
      return 'Invalid file format. Please choose a supported file type';
    } else {
      return 'An unexpected error occurred. Please try again';
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
