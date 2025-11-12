// Updated JobseekerProfileScreen.dart
// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jobapp/Feature/JobSeeker/jobseekers_screens/jobseekerprofile_information.dart';
import 'package:jobapp/Feature/JobSeeker/modelclass/jobseeker_info.dart';
import 'package:jobapp/Feature/JobSeeker/provider/jobseeker_provider.dart';
import 'package:jobapp/core/providers/theme_provider.dart';
import 'package:jobapp/Authentication/auth_state.dart';

import 'jobseekers_screens.dart';

class JobseekerProfileScreen extends ConsumerStatefulWidget {
  const JobseekerProfileScreen({super.key});

  @override
  ConsumerState<JobseekerProfileScreen> createState() => _YourScreenState();
}

class _YourScreenState extends ConsumerState<JobseekerProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load jobseeker info when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobseekerProvider.notifier).loadJobseekerInfo();
    });
  }

  void _toggleTheme() {
    ref.read(themeModeProvider.notifier).toggleTheme();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Perform logout
                await ref.read(authStateProvider.notifier).signOut();
                // Navigate to login screen
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  context.go('/login'); // Adjust route as needed
                }
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobseekerState = ref.watch(jobseekerProvider);
    final jobseekerInfo = jobseekerState.jobseekerInfo;
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.3),
                colorScheme.onPrimary,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.04, 0.3],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: buildstartingrow(height, width, themeMode),
              ),
              SizedBox(height: height * 0.02),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: buildheadercontainer(
                  height,
                  width,
                  jobseekerInfo,
                  colorScheme,
                ),
              ),
              SizedBox(height: height * 0.02),
              buildacountsession(
                height,
                width,
                jobseekerInfo,
                themeMode,
                colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildstartingrow(double height, double width, ThemeMode themeMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: _toggleTheme,
              icon: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            IconButton(
              onPressed: _logout,
              icon: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildheadercontainer(
    double height,
    double width,
    JobseekerModel? jobseekerInfo,
    ColorScheme colorScheme,
  ) {
    // Handle null case first
    if (jobseekerInfo == null) {
      return Container(
        height: height * 0.2,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outline),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.04),
              colorScheme.primary.withValues(alpha: 0.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.06, 0.4],
          ),
        ),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: height * 0.2,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outline),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.06, 0.4],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: height * 0.024,
                  left: width * 0.05,
                  right: width * 0.06,
                ),
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: colorScheme.primary),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: jobseekerInfo.profileImageUrl.isNotEmpty
                        ? Image(
                            image: NetworkImage(jobseekerInfo.profileImageUrl),
                            height: height * 0.063,
                            width: width * 0.14,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildProfilePlaceholder(
                                height,
                                width,
                                colorScheme,
                              );
                            },
                          )
                        : _buildProfilePlaceholder(height, width, colorScheme),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(top: height * 0.01)),
                    Text(
                      jobseekerInfo.name.isNotEmpty
                          ? jobseekerInfo.name
                          : jobseekerInfo.email,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: height * 0.008),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width * 0.3,
                          child: Text(
                            jobseekerInfo.jobDesignation.isNotEmpty
                                ? jobseekerInfo.jobDesignation
                                : 'Designation',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: colorScheme.onPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: width * 0.04),
                        SizedBox(
                          width: width * 0.26,
                          child: Column(
                            children: [
                              Text(
                                jobseekerInfo.location.isNotEmpty
                                    ? jobseekerInfo.location
                                    : 'Location',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: colorScheme.onPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.03),
          Divider(
            height: height * 0.01,
            color: colorScheme.onPrimary.withValues(alpha: 0.5),
          ),
          Row(
            children: [
              buildemailheadercontainer(
                height,
                width,
                jobseekerInfo.email.isNotEmpty ? jobseekerInfo.email : '',
                colorScheme,
              ),
              buildemailheadercontainer(
                height,
                width,
                jobseekerInfo.contact.isNotEmpty ? jobseekerInfo.contact : '',
                colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePlaceholder(
    double height,
    double width,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: height * 0.063,
      width: width * 0.14,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: height * 0.03,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget buildemailheadercontainer(
    double height,
    double width,
    String text,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: height * 0.02, left: width * 0.02),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.onPrimary),
          color: colorScheme.onPrimary.withValues(alpha: 0.1),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: colorScheme.onPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildacountsession(
    double height,
    double width,
    JobseekerModel? jobseekerInfo,
    ThemeMode themeMode,
    ColorScheme colorScheme,
  ) {
    if (jobseekerInfo == null) {
      return Container(
        height: height * 0.2,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outline),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.04),
              colorScheme.primary.withValues(alpha: 0.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.06, 0.4],
          ),
        ),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Container(
      height: height * 0.78,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: height * 0.01),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
                border: Border.all(
                  color: colorScheme.outline,
                ), // Changed from AppColors.grey
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileInformationScreen(),
                          ),
                        );
                      },
                      child: _buildAccountRow(
                        icon: Icons.person_outline,
                        title: 'Profile Information',
                        subtitle: 'View and edit',
                        hasArrow: true,
                        width: width,
                        height: height,
                        colorScheme: colorScheme,
                      ),
                    ),
                    Divider(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ), // Changed from AppColors.grey
                    // Row 2: Email - NO ACTION
                    _buildAccountRow(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: jobseekerInfo.email.isNotEmpty == true
                          ? jobseekerInfo.email
                          : 'Not set',
                      hasArrow: false, // No arrow for email
                      width: width,
                      height: height,
                      colorScheme: colorScheme,
                    ),
                    Divider(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ), // Changed from AppColors.grey
                    // Row 3: Age - NO ACTION
                    _buildAccountRow(
                      icon: Iconsax.heart,
                      title: 'Age',
                      subtitle: jobseekerInfo.age > 0
                          ? '${jobseekerInfo.age} years'
                          : 'Not set',
                      hasArrow: false,
                      width: width,
                      height: height,
                      colorScheme: colorScheme,
                    ),
                    Divider(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ), // Changed from AppColors.grey
                    // Row 4: Profession - NO ACTION
                    _buildAccountRow(
                      icon: Icons.work_outline,
                      title: 'Profession',
                      subtitle: jobseekerInfo.jobDesignation.isNotEmpty == true
                          ? jobseekerInfo.jobDesignation
                          : 'Not set',
                      hasArrow: false, // No arrow for profession
                      width: width,
                      height: height,
                      colorScheme: colorScheme,
                    ),
                    Divider(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ), // Changed from AppColors.grey
                    InkWell(
                      onTap: () {
                        _showContactUsOptions(context);
                      },
                      child: _buildAccountRow(
                        icon: Icons.report_problem_outlined,
                        title: 'Contact Us',
                        subtitle: 'select',
                        hasArrow: true, // No arrow for profession
                        width: width,
                        height: height,
                        colorScheme: colorScheme,
                      ),
                    ),
                    Divider(color: colorScheme.outline.withValues(alpha: 0.3)),
                    // Row 5: Theme Toggle
                    GestureDetector(
                      onTap: _toggleTheme,
                      child: _buildAccountRow(
                        icon: themeMode == ThemeMode.dark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        title: 'Theme',
                        subtitle: themeMode == ThemeMode.dark
                            ? 'Light Mode'
                            : 'Dark Mode',
                        hasArrow: true,
                        width: width,
                        height: height,
                        colorScheme: colorScheme,
                      ),
                    ),
                    Divider(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ), // Changed from AppColors.grey
                    // Row 6: Logout - WITH ACTION
                    GestureDetector(
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                      child: _buildAccountRow(
                        icon: Iconsax.logout_14,
                        title: 'Logout',
                        subtitle: '',
                        hasArrow: true,
                        textColor: Colors.red,
                        width: width,
                        height: height,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactUsOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.warning_amber, color: Colors.orange),
                title: Text('Report an Issue'),
                subtitle: Text('Technical problems or bugs'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ContactUsScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.report_problem, color: Colors.red),
                title: Text('Make a Report'),
                subtitle: Text('Report inappropriate content or behavior'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ContactUsScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool hasArrow,
    Color textColor = Colors.black,
    required double width,
    required double height,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: width * 0.07,
            height: height * 0.03,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: colorScheme.onSurface),
          ),
          SizedBox(width: width * 0.012),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: width * 0.38,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: textColor == Colors.red
                          ? textColor
                          : colorScheme.onSurface, // Changed from Colors.black
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Spacer(),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 09,
                      color: colorScheme
                          .onSurfaceVariant, // Changed from AppColors.grey
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          SizedBox(width: width * 0.01),
          if (hasArrow)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ), // Changed from AppColors.grey
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Perform logout
              await ref.read(authStateProvider.notifier).signOut();
              // Navigate to login screen
              if (mounted) {
                // ignore: use_build_context_synchronously
                context.go('/login'); // Adjust route as needed
              }
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
