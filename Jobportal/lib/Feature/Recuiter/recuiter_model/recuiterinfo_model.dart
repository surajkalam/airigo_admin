// models/recruiter_model.dart
class RecruiterModel {
  final String id;
  final String name;
  final String email;
  final String contact;
  final String companyName;
  final String designation;
  final String location;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RecruiterModel({
    required this.id,
    required this.name,
    required this.email,
    required this.contact,
    required this.companyName,
    required this.designation,
    required this.location,
    required this.photoUrl,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'contact': contact,
      'companyName': companyName,
      'designation': designation,
      'location': location,
      'photoUrl': photoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory RecruiterModel.fromMap(Map<String, dynamic> map) {
    return RecruiterModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      contact: map['contact'] ?? '',
      companyName: map['companyName'] ?? '',
      designation: map['designation'] ?? '',
      location: map['location'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  RecruiterModel copyWith({
    String? name,
    String? email,
    String? contact,
    String? companyName,
    String? designation,
    String? location,
    String? photoUrl,
    DateTime? updatedAt,
  }) {
    return RecruiterModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      companyName: companyName ?? this.companyName,
      designation: designation ?? this.designation,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}