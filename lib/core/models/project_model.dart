// lib/core/models/project_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  String? id;
  String userId; // Student ID
  String title;
  String description;
  String projectType; // e.g., 'web', 'mobile', 'desktop', 'ai', 'game', etc.
  String? githubUrl;
  String? liveUrl; // Demo or live site URL
  List<String> images; // Image URLs from Firebase Storage
  List<String>? technologies; // e.g., ['Flutter', 'Firebase', 'Dart']
  DateTime createdAt;
  DateTime? updatedAt;

  ProjectModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.projectType,
    this.githubUrl,
    this.liveUrl,
    required this.images,
    this.technologies,
    required this.createdAt,
    this.updatedAt,
  });

  // Date parser
  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map, String id) {
    final created = _parseDate(map['createdAt']) ?? DateTime.now();

    // Parse images
    List<String> imagesList = [];
    final imagesRaw = map['images'];
    if (imagesRaw is List) {
      imagesList = List<String>.from(imagesRaw);
    }

    // Parse technologies
    List<String>? technologiesList;
    final technologiesRaw = map['technologies'];
    if (technologiesRaw is List) {
      technologiesList = List<String>.from(technologiesRaw);
    }

    return ProjectModel(
      id: id,
      userId: map['userId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      projectType: map['projectType']?.toString() ?? 'diğer',
      githubUrl: map['githubUrl']?.toString(),
      liveUrl: map['liveUrl']?.toString(),
      images: imagesList,
      technologies: technologiesList,
      createdAt: created,
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    final data = <String, dynamic>{
      'userId': userId,
      'title': title.trim(),
      'description': description.trim(),
      'projectType': projectType.trim(),
      'images': images,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!isUpdate) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    if (githubUrl != null && githubUrl!.trim().isNotEmpty) {
      data['githubUrl'] = githubUrl!.trim();
    }
    if (liveUrl != null && liveUrl!.trim().isNotEmpty) {
      data['liveUrl'] = liveUrl!.trim();
    }
    if (technologies != null && technologies!.isNotEmpty) {
      data['technologies'] = technologies;
    }

    return data;
  }

  ProjectModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? projectType,
    String? githubUrl,
    String? liveUrl,
    List<String>? images,
    List<String>? technologies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      projectType: projectType ?? this.projectType,
      githubUrl: githubUrl ?? this.githubUrl,
      liveUrl: liveUrl ?? this.liveUrl,
      images: images ?? this.images,
      technologies: technologies ?? this.technologies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

