// lib/core/services/quiz_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const Duration _timeoutDuration = Duration(seconds: 15);

  // Add quiz
  Future<String> addQuiz(QuizModel quiz) async {
    try {
      final docRef = await _firestore
          .collection('quizzes')
          .add(quiz.toMap(isUpdate: false))
          .timeout(_timeoutDuration);
      
      return docRef.id;
    } catch (e) {
      print('Quiz ekleme hatası: $e');
      throw Exception('Quiz eklenemedi: ${e.toString()}');
    }
  }

  // Update quiz
  Future<void> updateQuiz(QuizModel quiz) async {
    if (quiz.id == null) {
      throw Exception('Quiz ID bulunamadı');
    }

    try {
      await _firestore
          .collection('quizzes')
          .doc(quiz.id)
          .update(quiz.toMap(isUpdate: true))
          .timeout(_timeoutDuration);
    } catch (e) {
      print('Quiz güncelleme hatası: $e');
      throw Exception('Quiz güncellenemedi: ${e.toString()}');
    }
  }

  // Delete quiz
  Future<void> deleteQuiz(String quizId) async {
    try {
      await _firestore
          .collection('quizzes')
          .doc(quizId)
          .delete()
          .timeout(_timeoutDuration);
    } catch (e) {
      print('Quiz silme hatası: $e');
      throw Exception('Quiz silinemedi: ${e.toString()}');
    }
  }

  // Get all active quizzes (for students)
  Future<List<QuizModel>> getActiveQuizzes({String? category}) async {
    try {
      Query query = _firestore
          .collection('quizzes')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (category != null && category.isNotEmpty && category != 'tümü') {
        query = query.where('category', isEqualTo: category);
      }

      final querySnapshot = await query.get().timeout(_timeoutDuration);

      return querySnapshot.docs
          .map((doc) => QuizModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((quiz) => quiz.isOpen)
          .toList();
    } catch (e) {
      print('Quiz getirme hatası: $e');
      return [];
    }
  }

  // Get quizzes by company
  Future<List<QuizModel>> getCompanyQuizzes(String companyId) async {
    try {
      final querySnapshot = await _firestore
          .collection('quizzes')
          .where('companyId', isEqualTo: companyId)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(_timeoutDuration);

      return querySnapshot.docs
          .map((doc) => QuizModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Şirket quizleri getirme hatası: $e');
      return [];
    }
  }

  // Get quiz by ID
  Future<QuizModel?> getQuizById(String quizId) async {
    try {
      final doc = await _firestore
          .collection('quizzes')
          .doc(quizId)
          .get()
          .timeout(_timeoutDuration);

      if (!doc.exists) return null;

      return QuizModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('Quiz getirme hatası: $e');
      return null;
    }
  }

  // Stream active quizzes (for real-time updates)
  Stream<List<QuizModel>> streamActiveQuizzes({String? category}) {
    Query query = _firestore
        .collection('quizzes')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (category != null && category.isNotEmpty && category != 'tümü') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => QuizModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((quiz) => quiz.isOpen)
          .toList();
    });
  }
}

