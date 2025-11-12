// pdf_upload_service.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class PdfUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Pick PDF using FilePicker
  Future<File?> pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick PDF: $e');
    }
  }

  // Upload PDF to Firebase Storage
  Future<String> uploadPdf(File pdfFile, String email, String name) async {
    try {
      // Create storage path: resumes/email/filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalFileName = getFileNameFromPath(pdfFile.path);
      final fileExtension = originalFileName.split('.').last.toLowerCase();
      
      String fileName = 'resume_${name}_$timestamp.$fileExtension';
      
      // Sanitize email for use in file path
      final sanitizedEmail = email.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      
      Reference storageRef = _storage.ref().child('resumes/$sanitizedEmail/$fileName');
      
      // Upload file
      UploadTask uploadTask = storageRef.putFile(
        pdfFile,
        SettableMetadata(
          contentType: _getMimeType(fileExtension),
          customMetadata: {
            'uploadedBy': email,
            'userName': name,
            'originalFileName': originalFileName,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload PDF: $e');
    }
  }
String _getMimeType(String extension) {
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  // Get file name from path
  String getFileNameFromPath(String path) {
    return path.split('/').last;
  }
}
String getFileSize(File file) {
    final sizeInBytes = file.lengthSync();
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1048576) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeInBytes / 1048576).toStringAsFixed(1)} MB';
    }
  }

// Provider for PDF upload service
final pdfUploadServiceProvider = Provider<PdfUploadService>((ref) {
  return PdfUploadService();
});