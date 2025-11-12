// jobseeker_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class JobseekerModel {
  final String id;
  final String name;
  final String email;
  final String contact;
  final String qualification;
  final String jobDesignation;
  final String location;
  final String experience;
  final String dateOfBirth;
  final String resumeUrl;
  final String resumeFileName;
  final DateTime createdAt;
  final DateTime? updatedAt;
   final String profileImageUrl; 

  JobseekerModel({
    this.id = '',
    required this.name,
    required this.email,
    required this.contact,
    required this.qualification,
    required this.jobDesignation,
    required this.location,
    required this.experience,
    required this.dateOfBirth,
    required this.resumeUrl,
    this.resumeFileName = '',
    required this.createdAt,
    this.updatedAt,
    this.profileImageUrl = '',
  });
   // Calculate age from dateOfBirth
  int get age {
    if (dateOfBirth.isEmpty) return 0;
    
    try {
      // Parse date in DD/MM/YYYY format
      final parts = dateOfBirth.split('/');
      if (parts.length != 3) return 0;
      
      final day = int.tryParse(parts[0]) ?? 0;
      final month = int.tryParse(parts[1]) ?? 0;
      final year = int.tryParse(parts[2]) ?? 0;
      
      if (day == 0 || month == 0 || year == 0) return 0;
      
      final birthDate = DateTime(year, month, day);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      
      // Adjust age if birthday hasn't occurred this year
      if (now.month < birthDate.month || 
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      
      return age;
    } catch (e) {
      return 0;
    }
  }
  Map<String, dynamic> toMap() {
    return {
       'jobseeker_id': id,
      'name': name,
      'email': email,
      'contact': contact,
      'qualification': qualification,
      'jobDesignation': jobDesignation,
      'location': location,
      'experience': experience,
      'dateOfBirth': dateOfBirth,
      'resumeUrl': resumeUrl,
      'resumeFileName': resumeFileName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
       'profileImageUrl': profileImageUrl,
    };
  }

  factory JobseekerModel.fromMap(String id, Map<String, dynamic> map) {
    return JobseekerModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      contact: map['contact'] ?? '',
      qualification: map['qualification'] ?? '',
      jobDesignation: map['jobDesignation'] ?? '',
      location: map['location'] ?? '',
      experience: map['experience'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      resumeUrl: map['resumeUrl'] ?? '',
      resumeFileName: map['resumeFileName'] ?? '',
        profileImageUrl: map['profileImageUrl'] ?? '',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  JobseekerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? contact,
    String? qualification,
    String? jobDesignation,
    String? location,
    String? experience,
    String? dateOfBirth,
    String? resumeUrl,
    String? resumeFileName,
    DateTime? createdAt,
    DateTime? updatedAt,
     String? profileImageUrl,
  }) {
    return JobseekerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      qualification: qualification ?? this.qualification,
      jobDesignation: jobDesignation ?? this.jobDesignation,
      location: location ?? this.location,
      experience: experience ?? this.experience,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
       profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}