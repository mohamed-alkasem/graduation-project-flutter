// lib/core/services/project_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const Duration _timeoutDuration = Duration(seconds: 15);

  // Add project
  Future<String> addProject(ProjectModel project) async {
    try {
      final docRef = await _firestore
          .collection('projects')
          .add(project.toMap(isUpdate: false))
          .timeout(_timeoutDuration);
      
      // Update student score after adding project
      updateStudentScore(project.userId);
      
      return docRef.id;
    } catch (e) {
      print('Proje ekleme hatası: $e');
      throw Exception('Proje eklenemedi: ${e.toString()}');
    }
  }

  // Update project
  Future<void> updateProject(ProjectModel project) async {
    if (project.id == null) {
      throw Exception('Proje ID bulunamadı');
    }

    try {
      await _firestore
          .collection('projects')
          .doc(project.id)
          .update(project.toMap(isUpdate: true))
          .timeout(_timeoutDuration);
      
      // Update student score after updating project
      updateStudentScore(project.userId);
    } catch (e) {
      print('Proje güncelleme hatası: $e');
      throw Exception('Proje güncellenemedi: ${e.toString()}');
    }
  }

  // Delete project
  Future<void> deleteProject(String projectId) async {
    try {
      // Get project to find userId before deleting
      final project = await getProjectById(projectId);
      final userId = project?.userId;
      
      await _firestore
          .collection('projects')
          .doc(projectId)
          .delete()
          .timeout(_timeoutDuration);
      
      // Update student score after deleting project
      if (userId != null) {
        updateStudentScore(userId);
      }
    } catch (e) {
      print('Proje silme hatası: $e');
      throw Exception('Proje silinemedi: ${e.toString()}');
    }
  }

  // Get all projects for a student
  Future<List<ProjectModel>> getStudentProjects(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('projects')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(_timeoutDuration);

      return querySnapshot.docs
          .map((doc) => ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Proje getirme hatası: $e');
      return [];
    }
  }

  // Get project by ID
  Future<ProjectModel?> getProjectById(String projectId) async {
    try {
      final doc = await _firestore
          .collection('projects')
          .doc(projectId)
          .get()
          .timeout(_timeoutDuration);

      if (!doc.exists) return null;

      return ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('Proje getirme hatası: $e');
      return null;
    }
  }

  // Stream projects for a student (for real-time updates)
  Stream<List<ProjectModel>> streamStudentProjects(String userId) {
    return _firestore
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get all projects (for company search)
  Future<List<ProjectModel>> getAllProjects({String? projectType}) async {
    try {
      Query query = _firestore
          .collection('projects')
          .orderBy('createdAt', descending: true);

      if (projectType != null && projectType.isNotEmpty && projectType != 'tümü') {
        query = query.where('projectType', isEqualTo: projectType);
      }

      final querySnapshot = await query.get().timeout(_timeoutDuration);

      return querySnapshot.docs
          .map((doc) => ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Proje getirme hatası: $e');
      return [];
    }
  }

  // Calculate score for a single project
  int _calculateProjectScore(ProjectModel project) {
    int score = 10; // Base score for each project

    // Bonus points
    if (project.githubUrl != null && project.githubUrl!.isNotEmpty) {
      score += 5; // GitHub URL bonus
    }
    if (project.liveUrl != null && project.liveUrl!.isNotEmpty) {
      score += 5; // Live URL bonus
    }
    if (project.images.isNotEmpty) {
      score += 3; // Images bonus
    }
    if (project.technologies != null && project.technologies!.isNotEmpty) {
      score += 5; // Technologies bonus
    }

    return score;
  }

  // Calculate and update student score based on all projects
  Future<void> updateStudentScore(String userId) async {
    try {
      final projects = await getStudentProjects(userId);
      
      int totalScore = 0;
      for (var project in projects) {
        totalScore += _calculateProjectScore(project);
      }

      // Update score in users collection
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'score': totalScore,
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(_timeoutDuration);
    } catch (e) {
      print('Score güncelleme hatası: $e');
      // Don't throw - score update failure shouldn't break project operations
    }
  }

  // Calculate and update scores for all existing students (one-time migration)
  Future<void> updateAllStudentsScores() async {
    try {
      print('🔄 Tüm öğrencilerin score hesaplanıyor...');
      
      // Get all students
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'ogrenci')
          .get()
          .timeout(const Duration(minutes: 5));

      int updatedCount = 0;
      int errorCount = 0;

      for (var doc in studentsSnapshot.docs) {
        try {
          final userId = doc.id;
          final projects = await getStudentProjects(userId);
          
          int totalScore = 0;
          for (var project in projects) {
            totalScore += _calculateProjectScore(project);
          }

          await _firestore
              .collection('users')
              .doc(userId)
              .update({
            'score': totalScore,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          updatedCount++;
          print('✅ Öğrenci ${doc.id}: $totalScore puan');
        } catch (e) {
          errorCount++;
          print('❌ Öğrenci ${doc.id} score güncelleme hatası: $e');
        }
      }

      print('✅ Score güncelleme tamamlandı: $updatedCount başarılı, $errorCount hata');
    } catch (e) {
      print('❌ Tüm öğrenci score güncelleme hatası: $e');
      throw Exception('Score güncelleme başarısız: ${e.toString()}');
    }
  }
}

