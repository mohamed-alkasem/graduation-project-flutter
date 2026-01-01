// lib/core/models/quiz_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel {
  String? id;
  String companyId; // ID of the company that created the quiz
  String companyName;
  String title;
  String description;
  String category; // e.g., 'programming', 'design', 'data_science', etc.
  List<QuizQuestion> questions;
  DateTime startDate;
  DateTime endDate;
  int durationMinutes; // Duration in minutes
  int maxScore;
  bool isActive;
  DateTime createdAt;
  DateTime? updatedAt;
  
  // For AI integration later
  String? aiModel; // AI model used for evaluation
  Map<String, dynamic>? aiConfig; // AI configuration

  QuizModel({
    this.id,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.description,
    required this.category,
    required this.questions,
    required this.startDate,
    required this.endDate,
    required this.durationMinutes,
    this.maxScore = 100,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.aiModel,
    this.aiConfig,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  factory QuizModel.fromMap(Map<String, dynamic> map, String id) {
    final created = _parseDate(map['createdAt']) ?? DateTime.now();
    final startDate = _parseDate(map['startDate']) ?? DateTime.now();
    final endDate = _parseDate(map['endDate']) ?? DateTime.now();

    // Parse questions
    List<QuizQuestion> questionsList = [];
    final questionsRaw = map['questions'];
    if (questionsRaw is List) {
      questionsList = questionsRaw.map((q) => QuizQuestion.fromMap(q)).toList();
    }

    return QuizModel(
      id: id,
      companyId: map['companyId']?.toString() ?? '',
      companyName: map['companyName']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'diğer',
      questions: questionsList,
      startDate: startDate,
      endDate: endDate,
      durationMinutes: map['durationMinutes'] as int? ?? 60,
      maxScore: map['maxScore'] as int? ?? 100,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: created,
      updatedAt: _parseDate(map['updatedAt']),
      aiModel: map['aiModel']?.toString(),
      aiConfig: map['aiConfig'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    final data = <String, dynamic>{
      'companyId': companyId,
      'companyName': companyName.trim(),
      'title': title.trim(),
      'description': description.trim(),
      'category': category.trim(),
      'questions': questions.map((q) => q.toMap()).toList(),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'durationMinutes': durationMinutes,
      'maxScore': maxScore,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!isUpdate) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    if (aiModel != null && aiModel!.trim().isNotEmpty) {
      data['aiModel'] = aiModel!.trim();
    }
    if (aiConfig != null) {
      data['aiConfig'] = aiConfig;
    }

    return data;
  }

  bool get isOpen {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }
}

class QuizQuestion {
  String question;
  String questionType; // 'multiple_choice', 'text', 'code'
  List<String>? options; // For multiple choice
  String? correctAnswer; // For multiple choice or simple text
  int points;
  Map<String, dynamic>? metadata; // For AI evaluation later

  QuizQuestion({
    required this.question,
    required this.questionType,
    this.options,
    this.correctAnswer,
    this.points = 10,
    this.metadata,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    List<String>? optionsList;
    final optionsRaw = map['options'];
    if (optionsRaw is List) {
      optionsList = List<String>.from(optionsRaw);
    }

    return QuizQuestion(
      question: map['question']?.toString() ?? '',
      questionType: map['questionType']?.toString() ?? 'text',
      options: optionsList,
      correctAnswer: map['correctAnswer']?.toString(),
      points: map['points'] as int? ?? 10,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'question': question.trim(),
      'questionType': questionType.trim(),
      'points': points,
    };

    if (options != null && options!.isNotEmpty) {
      data['options'] = options;
    }
    if (correctAnswer != null && correctAnswer!.trim().isNotEmpty) {
      data['correctAnswer'] = correctAnswer!.trim();
    }
    if (metadata != null) {
      data['metadata'] = metadata;
    }

    return data;
  }
}

