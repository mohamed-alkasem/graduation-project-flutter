// lib/core/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String email;
  String name;
  String role; // 'ogrenci' or 'sirket'
  DateTime createdAt;

  // For Student
  String? studentNo;
  String? university;
  String? department;
  String? phone;
  List<String>? skills;

  // For Company
  String? companyName;
  String? sector;
  String? companyPhone;
  String? website;
  String? address;

  UserModel({
    this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,

    // Student fields
    this.studentNo,
    this.university,
    this.department,
    this.phone,
    this.skills,

    // Company fields
    this.companyName,
    this.sector,
    this.companyPhone,
    this.website,
    this.address,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    // Handle Timestamp conversion
    DateTime createdAt;
    if (map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      createdAt = DateTime.parse(map['createdAt']);
    } else {
      createdAt = DateTime.now();
    }

    // Handle skills list
    List<String> skillsList = [];
    if (map['skills'] != null) {
      if (map['skills'] is List) {
        skillsList = List<String>.from(map['skills']);
      } else if (map['skills'] is String) {
        skillsList = (map['skills'] as String).split(',').map((e) => e.trim()).toList();
      }
    }

    return UserModel(
      id: id,
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      createdAt: createdAt,

      // Student fields
      studentNo: map['studentNo']?.toString(),
      university: map['university']?.toString(),
      department: map['department']?.toString(),
      phone: map['phone']?.toString(),
      skills: skillsList,

      // Company fields
      companyName: map['companyName']?.toString(),
      sector: map['sector']?.toString(),
      companyPhone: map['companyPhone']?.toString(),
      website: map['website']?.toString(),
      address: map['address']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),

      // Student fields
      if (studentNo != null && studentNo!.isNotEmpty) 'studentNo': studentNo,
      if (university != null && university!.isNotEmpty) 'university': university,
      if (department != null && department!.isNotEmpty) 'department': department,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (skills != null && skills!.isNotEmpty) 'skills': skills,

      // Company fields
      if (companyName != null && companyName!.isNotEmpty) 'companyName': companyName,
      if (sector != null && sector!.isNotEmpty) 'sector': sector,
      if (companyPhone != null && companyPhone!.isNotEmpty) 'companyPhone': companyPhone,
      if (website != null && website!.isNotEmpty) 'website': website,
      if (address != null && address!.isNotEmpty) 'address': address,
    };
  }

  // Helper method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'studentNo': studentNo,
      'university': university,
      'department': department,
      'phone': phone,
      'skills': skills,
      'companyName': companyName,
      'sector': sector,
      'companyPhone': companyPhone,
      'website': website,
      'address': address,
    };
  }

  // Helper method to create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      studentNo: json['studentNo'],
      university: json['university'],
      department: json['department'],
      phone: json['phone'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      companyName: json['companyName'],
      sector: json['sector'],
      companyPhone: json['companyPhone'],
      website: json['website'],
      address: json['address'],
    );
  }

  // Check if user is student
  bool get isStudent => role == 'ogrenci';

  // Check if user is company
  bool get isCompany => role == 'sirket';

  // Get display name
  String get displayName {
    if (isCompany && companyName != null && companyName!.isNotEmpty) {
      return companyName!;
    }
    return name;
  }

  // Get user type for display
  String get userType {
    if (isStudent) return 'Öğrenci';
    if (isCompany) return 'Şirket';
    return 'Kullanıcı';
  }

  // Get formatted skills
  String get formattedSkills {
    if (skills == null || skills!.isEmpty) return 'Belirtilmemiş';
    return skills!.join(', ');
  }

  // Get user info summary
  String get summary {
    if (isStudent) {
      return '$university - $department';
    } else if (isCompany) {
      return '$sector - $address';
    }
    return role;
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
    String? studentNo,
    String? university,
    String? department,
    String? phone,
    List<String>? skills,
    String? companyName,
    String? sector,
    String? companyPhone,
    String? website,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      studentNo: studentNo ?? this.studentNo,
      university: university ?? this.university,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      skills: skills ?? this.skills,
      companyName: companyName ?? this.companyName,
      sector: sector ?? this.sector,
      companyPhone: companyPhone ?? this.companyPhone,
      website: website ?? this.website,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, email: $email, role: $role}';
  }
}