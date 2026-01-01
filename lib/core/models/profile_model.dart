// lib/core/models/profile_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  String? id;
  String userId;
  String email;
  String name;
  String role; // 'ogrenci' or 'sirket'
  DateTime createdAt;
  DateTime? updatedAt;

  // For Student
  String? studentNo;
  String? university;
  String? department;
  String? phone;
  List<String>? skills;
  String? about;
  String? profileImageUrl;
  String? githubUrl;
  String? linkedinUrl;
  String? portfolioUrl;

  // For Company
  String? companyName;
  String? sector;
  String? companyPhone;
  String? website;
  String? address;
  String? taxNo;
  String? contactPerson;
  String? companyLogoUrl;
  String? companyDescription;
  String? companySize; // küçük, orta, büyük
  String? status; // pending, approved, rejected, pending_approval, active

  // ✅ NEW (Admin info)
  String? adminEmail;        // yöneticinin maili
  String? rejectionReason;   // reddedilme sebebi

  ProfileModel({
    this.id,
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.updatedAt,

    // Student fields
    this.studentNo,
    this.university,
    this.department,
    this.phone,
    this.skills,
    this.about,
    this.profileImageUrl,
    this.githubUrl,
    this.linkedinUrl,
    this.portfolioUrl,

    // Company fields
    this.companyName,
    this.sector,
    this.companyPhone,
    this.website,
    this.address,
    this.taxNo,
    this.contactPerson,
    this.companyLogoUrl,
    this.companyDescription,
    this.companySize,
    this.status = 'pending',

    // ✅ NEW
    this.adminEmail,
    this.rejectionReason,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    return ProfileModel(
      id: id,
      userId: map['userId']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      createdAt: map['createdAt'] != null ? parseDate(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? parseDate(map['updatedAt']) : null,

      // Student fields
      studentNo: map['studentNo']?.toString(),
      university: map['university']?.toString(),
      department: map['department']?.toString(),
      phone: map['phone']?.toString(),
      skills: map['skills'] != null ? List<String>.from(map['skills']) : null,
      about: map['about']?.toString(),
      profileImageUrl: map['profileImageUrl']?.toString(),
      githubUrl: map['githubUrl']?.toString(),
      linkedinUrl: map['linkedinUrl']?.toString(),
      portfolioUrl: map['portfolioUrl']?.toString(),

      // Company fields
      companyName: map['companyName']?.toString(),
      sector: map['sector']?.toString(),
      companyPhone: map['companyPhone']?.toString(),
      website: map['website']?.toString(),
      address: map['address']?.toString(),
      taxNo: map['taxNo']?.toString(),
      contactPerson: map['contactPerson']?.toString(),
      companyLogoUrl: map['companyLogoUrl']?.toString(),
      companyDescription: map['companyDescription']?.toString(),
      companySize: map['companySize']?.toString(),
      status: map['status']?.toString() ?? 'pending',

      // ✅ NEW
      adminEmail: map['adminEmail']?.toString(),
      rejectionReason: map['rejectionReason']?.toString(),
    );
  }

  /// ✅ ملاحظة: createdAt ما لازم يتغير بالتحديث.
  /// لذلك نخليه stored value إذا موجود، وإلا نخليها serverTimestamp لأول إنشاء.
  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'role': role,

      if (!isUpdate) 'createdAt': createdAt, // أول مرة فقط
      'updatedAt': FieldValue.serverTimestamp(),

      // Student fields
      if (studentNo != null && studentNo!.isNotEmpty) 'studentNo': studentNo,
      if (university != null && university!.isNotEmpty) 'university': university,
      if (department != null && department!.isNotEmpty) 'department': department,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (skills != null && skills!.isNotEmpty) 'skills': skills,
      if (about != null && about!.isNotEmpty) 'about': about,
      if (profileImageUrl != null && profileImageUrl!.isNotEmpty) 'profileImageUrl': profileImageUrl,
      if (githubUrl != null && githubUrl!.isNotEmpty) 'githubUrl': githubUrl,
      if (linkedinUrl != null && linkedinUrl!.isNotEmpty) 'linkedinUrl': linkedinUrl,
      if (portfolioUrl != null && portfolioUrl!.isNotEmpty) 'portfolioUrl': portfolioUrl,

      // Company fields
      if (companyName != null && companyName!.isNotEmpty) 'companyName': companyName,
      if (sector != null && sector!.isNotEmpty) 'sector': sector,
      if (companyPhone != null && companyPhone!.isNotEmpty) 'companyPhone': companyPhone,
      if (website != null && website!.isNotEmpty) 'website': website,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (taxNo != null && taxNo!.isNotEmpty) 'taxNo': taxNo,
      if (contactPerson != null && contactPerson!.isNotEmpty) 'contactPerson': contactPerson,
      if (companyLogoUrl != null && companyLogoUrl!.isNotEmpty) 'companyLogoUrl': companyLogoUrl,
      if (companyDescription != null && companyDescription!.isNotEmpty) 'companyDescription': companyDescription,
      if (companySize != null && companySize!.isNotEmpty) 'companySize': companySize,
      if (status != null) 'status': status,

      // ✅ NEW
      if (adminEmail != null && adminEmail!.isNotEmpty) 'adminEmail': adminEmail,
      if (rejectionReason != null && rejectionReason!.isNotEmpty) 'rejectionReason': rejectionReason,
    };
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

  // Get formatted skills
  String get formattedSkills {
    if (skills == null || skills!.isEmpty) return 'Belirtilmemiş';
    return skills!.join(', ');
  }

  // Get profile completion percentage
  int get completionPercentage {
    int totalFields = 0;
    int completedFields = 0;

    if (email.isNotEmpty) completedFields++;
    totalFields++;

    if (name.isNotEmpty) completedFields++;
    totalFields++;

    if (isStudent) {
      if (studentNo?.isNotEmpty == true) completedFields++;
      totalFields++;

      if (university?.isNotEmpty == true) completedFields++;
      totalFields++;

      if (department?.isNotEmpty == true) completedFields++;
      totalFields++;

      if (phone?.isNotEmpty == true) completedFields++;
      totalFields++;

      if (skills?.isNotEmpty == true) completedFields++;
      totalFields++;

      if (about?.isNotEmpty == true) completedFields++;
      totalFields++;
    } else if (isCompany) {
      if (companyName?.isNotEmpty == true) completedFields++;
      totalFields++;

      if (sector?.isNotEmpty == true) completedFields++;
      totalFields++;

      if (companyPhone?.isNotEmpty == true) completedFields++;
      totalFields++;

      if (address?.isNotEmpty == true) completedFields++;
      totalFields++;

      if (companyDescription?.isNotEmpty == true) completedFields++;
      totalFields++;
    }

    return totalFields > 0 ? ((completedFields / totalFields) * 100).round() : 0;
  }

  // Copy with method for updates
  ProfileModel copyWith({
    String? id,
    String? userId,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? studentNo,
    String? university,
    String? department,
    String? phone,
    List<String>? skills,
    String? about,
    String? profileImageUrl,
    String? githubUrl,
    String? linkedinUrl,
    String? portfolioUrl,
    String? companyName,
    String? sector,
    String? companyPhone,
    String? website,
    String? address,
    String? taxNo,
    String? contactPerson,
    String? companyLogoUrl,
    String? companyDescription,
    String? companySize,
    String? status,

    // ✅ NEW
    String? adminEmail,
    String? rejectionReason,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentNo: studentNo ?? this.studentNo,
      university: university ?? this.university,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      skills: skills ?? this.skills,
      about: about ?? this.about,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      companyName: companyName ?? this.companyName,
      sector: sector ?? this.sector,
      companyPhone: companyPhone ?? this.companyPhone,
      website: website ?? this.website,
      address: address ?? this.address,
      taxNo: taxNo ?? this.taxNo,
      contactPerson: contactPerson ?? this.contactPerson,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      companyDescription: companyDescription ?? this.companyDescription,
      companySize: companySize ?? this.companySize,
      status: status ?? this.status,

      // ✅ NEW
      adminEmail: adminEmail ?? this.adminEmail,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
