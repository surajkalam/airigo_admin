// services/firebase_recruiter_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../recuiter_model/recuiter_model.dart';

class FirebaseRecruiterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection reference
  CollectionReference get _recruitersCollection => _firestore.collection('recruiters');

  // Upload image to Firebase Storage and return download URL
  Future<String> uploadImage(File imageFile, String email) async {
    try {
      // Check if file exists and is accessible
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist or is inaccessible');
      }

      // Check file size (optional)
      final fileLength = await imageFile.length();
      if (fileLength > 10 * 1024 * 1024) { // 10MB limit
        throw Exception('Image file is too large. Maximum size is 10MB');
      }

      String fileName = 'recruiter_photos/$email/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageReference = _storage.ref().child(fileName);
      
      // Add metadata for better error handling
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': imageFile.path},
      );

      UploadTask uploadTask = storageReference.putFile(imageFile, metadata);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Save recruiter data to Firestore using email as document ID
  Future<void> saveRecruiterData(RecruiterModel recruiter) async {
    try {
      await _recruitersCollection.doc(recruiter.email).set(recruiter.toMap());
    } catch (e) {
      throw Exception('Failed to save recruiter data: $e');
    }
  }

  // Get recruiter data by email
  Future<RecruiterModel?> getRecruiterByEmail(String email) async {
    try {
      DocumentSnapshot snapshot = await _recruitersCollection.doc(email).get();
      if (snapshot.exists) {
        return RecruiterModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch recruiter data: $e');
    }
  }

  // Update recruiter data
  Future<void> updateRecruiterData(RecruiterModel recruiter) async {
    try {
      await _recruitersCollection.doc(recruiter.email).update({
        'name': recruiter.name,
        'contact': recruiter.contact,
        'companyName': recruiter.companyName,
        'designation': recruiter.designation,
        'location': recruiter.location,
        'photoUrl': recruiter.photoUrl,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update recruiter data: $e');
    }
  }
  Stream<List<RecruiterModel>> getAllRecruiters() {
  return _firestore
      .collection('recruiters')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => RecruiterModel.fromMap(doc.data()))
          .toList());
}
}