// resume_viewer_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jobapp/core/util/appcolors.dart';

class ResumeViewerScreen extends StatelessWidget {
  final String resumeUrl;
  final String resumeFileName;

  const ResumeViewerScreen({
    super.key,
    required this.resumeUrl,
    required this.resumeFileName,
  });
  Future<void> _launchResume() async {
    try {
      final Uri url = Uri.parse(resumeUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $resumeUrl');
      }
    } catch (e) {
      throw Exception('Failed to open resume: $e');
    }
  }
  void _showDownloadOptions(BuildContext context, double height, double width) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Resume Options',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: height * 0.02),
            ListTile(
              leading: Icon(Icons.open_in_browser, color: AppColors.lightBlue),
              title: Text('Open in Browser'),
              subtitle: Text('View resume in web browser'),
              onTap: () {
                Navigator.pop(context);
                _launchResume();
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: Colors.green),
              title: Text('Download Resume'),
              subtitle: Text('Save to your device'),
              onTap: () {
                Navigator.pop(context);
                _downloadResume(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _downloadResume(BuildContext context) async {
    try {
      // For download, we can use the same URL but suggest download
      final Uri url = Uri.parse(resumeUrl);
      if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
        _showSnackBar(
          // ignore: use_build_context_synchronously
          context: context,
          text: 'Resume download started',
          textColor: Colors.deepOrange,
        );
      }
    } catch (e) {
      _showSnackBar(
        // ignore: use_build_context_synchronously
        context: context,
        text: 'Failed to download resume: $e',
        textColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Resume Viewer',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.download_outlined, color: AppColors.darkblue),
            onPressed: () => _showDownloadOptions(context, height, width),
            tooltip: 'Download Options',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Resume Preview Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
                  color: AppColors.verylightblue.withValues(alpha: 0.1),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getFileIcon(resumeFileName),
                      size: 64,
                      color: AppColors.darkblue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      resumeFileName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      'Click the button below to view your resume',
                      style: TextStyle(fontSize: 11, color: AppColors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.017),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Icon(Icons.link, size: 16, color: AppColors.grey),
                    //     SizedBox(width: 8),
                    //     Expanded(
                    //       child: Text(
                    //         resumeUrl,
                    //         style: TextStyle(
                    //           fontSize: 10,
                    //           color: AppColors.grey,
                    //         ),
                    //         overflow: TextOverflow.ellipsis,
                    //         textAlign: TextAlign.center,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.03),
              // Open Resume Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _launchResume,
                  icon: Icon(Icons.visibility_outlined, size: 18),
                  label: Text(
                    'Open Resume',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(width, height * 0.07),
                    backgroundColor: AppColors.lightBlue,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.03),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadResume(context),
                      icon: Icon(Icons.download, size: 18),
                      label: Text(
                        'Download',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkblue,
                        side: BorderSide(color: AppColors.darkblue),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.04),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showDownloadOptions(context, height, width),
                      icon: Icon(Icons.share, size: 18),
                      label: Text(
                        'Share',

                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              // Information Section
              SizedBox(height: height * 0.04),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.verylightblue.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resume Information',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: height * 0.015),
                    _buildInfoItem('File Name', resumeFileName),
                    _buildInfoItem('File Type', _getFileType(resumeFileName)),
                    _buildInfoItem('Uploaded', 'Available for employers'),
                    _buildInfoItem('Status', 'Active'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileName.toLowerCase().endsWith('.doc') ||
        fileName.toLowerCase().endsWith('.docx')) {
      return Icons.description;
    } else {
      return Icons.insert_drive_file;
    }
  }

  String _getFileType(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return 'PDF Document';
    } else if (fileName.toLowerCase().endsWith('.doc')) {
      return 'Word Document (DOC)';
    } else if (fileName.toLowerCase().endsWith('.docx')) {
      return 'Word Document (DOCX)';
    } else {
      return 'Document';
    }
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
}
