// lib/core/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String email;
  String name;
  String role; // 'ogrenci' or 'sirket'
  DateTime createdAt;
  DateTime? updatedAt;

  // Student
  String? studentNo;
  String? university;
  String? department;
  String? phone;
  List<String>? skills;
  String? bio;
  String? grade; // الصف (السنة الدراسية)
  List<String>? hobbies; // الهوايات
  int score; // Puan (projeler ve aktivitelere göre)

  // Company
  String? companyName;
  String? sector;
  String? companyPhone;
  String? website;
  String? address;
  String? companyDescription;

  // (اختياري) status بسيط فقط
  String status; // active, suspended (إذا ما بدك نهائياً احذفه كمان)

  UserModel({
    this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.updatedAt,

    // Student
    this.studentNo,
    this.university,
    this.department,
    this.phone,
    this.skills,
    this.bio,
    this.grade,
    this.hobbies,
    this.score = 0,

    // Company
    this.companyName,
    this.sector,
    this.companyPhone,
    this.website,
    this.address,
    this.companyDescription,

    this.status = 'active',
  });

  // ===== Date parser =====
  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    final created = _parseDate(map['createdAt']) ?? DateTime.now();

    // skills
    List<String>? skillsList;
    final skillsRaw = map['skills'];
    if (skillsRaw is List) {
      skillsList = List<String>.from(skillsRaw);
    } else if (skillsRaw is String && skillsRaw.trim().isNotEmpty) {
      skillsList = skillsRaw.split(',').map((e) => e.trim()).toList();
    }

    // hobbies
    List<String>? hobbiesList;
    final hobbiesRaw = map['hobbies'];
    if (hobbiesRaw is List) {
      hobbiesList = List<String>.from(hobbiesRaw);
    } else if (hobbiesRaw is String && hobbiesRaw.trim().isNotEmpty) {
      hobbiesList = hobbiesRaw.split(',').map((e) => e.trim()).toList();
    }

    return UserModel(
      id: id,
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      createdAt: created,
      updatedAt: _parseDate(map['updatedAt']),

      // Student
      studentNo: map['studentNo']?.toString(),
      university: map['university']?.toString(),
      department: map['department']?.toString(),
      phone: map['phone']?.toString(),
      skills: skillsList,
      bio: map['bio']?.toString(),
      grade: map['grade']?.toString(),
      hobbies: hobbiesList,
      score: (map['score'] as num?)?.toInt() ?? 0,

      // Company
      companyName: map['companyName']?.toString(),
      sector: map['sector']?.toString(),
      companyPhone: map['companyPhone']?.toString(),
      website: map['website']?.toString(),
      address: map['address']?.toString(),
      companyDescription: map['companyDescription']?.toString(),

      status: map['status']?.toString() ?? 'active',
    );
  }

  /// toMap:
  /// - create: createdAt serverTimestamp
  /// - update: don't touch createdAt
  /// - always: updatedAt serverTimestamp
  Map<String, dynamic> toMap({bool isUpdate = false}) {
    final data = <String, dynamic>{
      'email': email.trim(),
      'name': name.trim(),
      'role': role,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!isUpdate) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    // Student
    if (studentNo != null && studentNo!.trim().isNotEmpty) data['studentNo'] = studentNo!.trim();
    if (university != null && university!.trim().isNotEmpty) data['university'] = university!.trim();
    if (department != null && department!.trim().isNotEmpty) data['department'] = department!.trim();
    if (phone != null && phone!.trim().isNotEmpty) data['phone'] = phone!.trim();
    if (skills != null && skills!.isNotEmpty) data['skills'] = skills;
    if (bio != null && bio!.trim().isNotEmpty) data['bio'] = bio!.trim();
    if (grade != null && grade!.trim().isNotEmpty) data['grade'] = grade!.trim();
    if (hobbies != null && hobbies!.isNotEmpty) data['hobbies'] = hobbies;
    data['score'] = score;

    // Company
    if (companyName != null && companyName!.trim().isNotEmpty) data['companyName'] = companyName!.trim();
    if (sector != null && sector!.trim().isNotEmpty) data['sector'] = sector!.trim();
    if (companyPhone != null && companyPhone!.trim().isNotEmpty) data['companyPhone'] = companyPhone!.trim();
    if (website != null && website!.trim().isNotEmpty) data['website'] = website!.trim();
    if (address != null && address!.trim().isNotEmpty) data['address'] = address!.trim();
    if (companyDescription != null && companyDescription!.trim().isNotEmpty) {
      data['companyDescription'] = companyDescription!.trim();
    }

    return data;
  }

  // Helpers
  bool get isStudent => role == 'ogrenci';
  bool get isCompany => role == 'sirket';

  String get displayName {
    if (isCompany && companyName != null && companyName!.isNotEmpty) return companyName!;
    return name;
  }

  String get formattedSkills {
    if (skills == null || skills!.isEmpty) return 'Belirtilmemiş';
    return skills!.join(', ');
  }

  String get summary {
    if (isStudent) return '${university ?? ''} - ${department ?? ''}'.trim();
    if (isCompany) return '${sector ?? ''} - ${address ?? ''}'.trim();
    return role;
  }

  UserModel copyWith({
    String? id,
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
    String? bio,
    String? grade,
    List<String>? hobbies,
    int? score,
    String? companyName,
    String? sector,
    String? companyPhone,
    String? website,
    String? address,
    String? companyDescription,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
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
      bio: bio ?? this.bio,
      grade: grade ?? this.grade,
      hobbies: hobbies ?? this.hobbies,
      score: score ?? this.score,
      companyName: companyName ?? this.companyName,
      sector: sector ?? this.sector,
      companyPhone: companyPhone ?? this.companyPhone,
      website: website ?? this.website,
      address: address ?? this.address,
      companyDescription: companyDescription ?? this.companyDescription,
      status: status ?? this.status,
    );
  }

  @override
  String toString() => 'UserModel{id: $id, name: $name, email: $email, role: $role, status: $status}';
}
