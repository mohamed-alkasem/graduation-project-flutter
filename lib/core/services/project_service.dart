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
    } catch (e) {
      print('Proje güncelleme hatası: $e');
      throw Exception('Proje güncellenemedi: ${e.toString()}');
    }
  }

  // Delete project
  Future<void> deleteProject(String projectId) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .delete()
          .timeout(_timeoutDuration);
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
}

