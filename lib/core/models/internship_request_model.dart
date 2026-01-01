// lib/core/models/internship_request_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class InternshipRequestModel {
  String? id;
  String companyId;
  String companyName;
  String title;
  String description;
  String category; // e.g., 'programming', 'design', 'marketing', etc.
  String location; // Şehir/Konum
  DateTime startDate;
  DateTime endDate;
  DateTime applicationDeadline;
  bool isActive;
  List<String> requirements; // المتطلبات (skills, qualifications)
  List<String> requiredDocuments; // الملفات المطلوبة (CV, Portfolio, etc.)
  int? maxApplications; // الحد الأقصى لعدد المتقدمين
  DateTime createdAt;
  DateTime? updatedAt;

  InternshipRequestModel({
    this.id,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.applicationDeadline,
    this.isActive = true,
    required this.requirements,
    required this.requiredDocuments,
    this.maxApplications,
    required this.createdAt,
    this.updatedAt,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  factory InternshipRequestModel.fromMap(Map<String, dynamic> map, String id) {
    final created = _parseDate(map['createdAt']) ?? DateTime.now();
    final startDate = _parseDate(map['startDate']) ?? DateTime.now();
    final endDate = _parseDate(map['endDate']) ?? DateTime.now();
    final deadline = _parseDate(map['applicationDeadline']) ?? DateTime.now();

    List<String> requirementsList = [];
    final reqRaw = map['requirements'];
    if (reqRaw is List) {
      requirementsList = List<String>.from(reqRaw);
    }

    List<String> documentsList = [];
    final docsRaw = map['requiredDocuments'];
    if (docsRaw is List) {
      documentsList = List<String>.from(docsRaw);
    }

    return InternshipRequestModel(
      id: id,
      companyId: map['companyId']?.toString() ?? '',
      companyName: map['companyName']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'diğer',
      location: map['location']?.toString() ?? '',
      startDate: startDate,
      endDate: endDate,
      applicationDeadline: deadline,
      isActive: map['isActive'] as bool? ?? true,
      requirements: requirementsList,
      requiredDocuments: documentsList,
      maxApplications: map['maxApplications'] as int?,
      createdAt: created,
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    final data = <String, dynamic>{
      'companyId': companyId,
      'companyName': companyName.trim(),
      'title': title.trim(),
      'description': description.trim(),
      'category': category.trim(),
      'location': location.trim(),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'applicationDeadline': Timestamp.fromDate(applicationDeadline),
      'isActive': isActive,
      'requirements': requirements,
      'requiredDocuments': requiredDocuments,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!isUpdate) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    if (maxApplications != null) {
      data['maxApplications'] = maxApplications;
    }

    return data;
  }

  bool get isOpen {
    final now = DateTime.now();
    return isActive && now.isBefore(applicationDeadline);
  }
}

// Application Model - طلب التقديم من الطالب
class InternshipApplicationModel {
  String? id;
  String internshipRequestId;
  String studentId;
  String studentName;
  String studentEmail;
  String status; // 'pending', 'accepted', 'rejected'
  Map<String, String>? uploadedDocuments; // documentType -> fileURL
  String? coverLetter; // خطاب التقديم
  DateTime createdAt;
  DateTime? updatedAt;

  InternshipApplicationModel({
    this.id,
    required this.internshipRequestId,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    this.status = 'pending',
    this.uploadedDocuments,
    this.coverLetter,
    required this.createdAt,
    this.updatedAt,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  factory InternshipApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    final created = _parseDate(map['createdAt']) ?? DateTime.now();

    Map<String, String>? documents;
    final docsRaw = map['uploadedDocuments'];
    if (docsRaw is Map) {
      documents = Map<String, String>.from(docsRaw);
    }

    return InternshipApplicationModel(
      id: id,
      internshipRequestId: map['internshipRequestId']?.toString() ?? '',
      studentId: map['studentId']?.toString() ?? '',
      studentName: map['studentName']?.toString() ?? '',
      studentEmail: map['studentEmail']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      uploadedDocuments: documents,
      coverLetter: map['coverLetter']?.toString(),
      createdAt: created,
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    final data = <String, dynamic>{
      'internshipRequestId': internshipRequestId,
      'studentId': studentId,
      'studentName': studentName.trim(),
      'studentEmail': studentEmail.trim(),
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!isUpdate) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    if (uploadedDocuments != null && uploadedDocuments!.isNotEmpty) {
      data['uploadedDocuments'] = uploadedDocuments;
    }
    if (coverLetter != null && coverLetter!.trim().isNotEmpty) {
      data['coverLetter'] = coverLetter!.trim();
    }

    return data;
  }
}

