// lib/core/services/student_search_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import 'project_service.dart';

class StudentSearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProjectService _projectService = ProjectService();
  static const Duration _timeoutDuration = Duration(seconds: 15);

  // Search students with filters
  Future<List<StudentSearchResult>> searchStudents({
    String? department,
    String? skill,
    String? projectType,
    String? searchQuery, // For name or other text search
  }) async {
    try {
      // Start with all students
      Query query = _firestore
          .collection('users')
          .where('role', isEqualTo: 'ogrenci')
          .where('status', isEqualTo: 'active');

      // Apply department filter
      if (department != null && department.isNotEmpty && department != 'tümü') {
        query = query.where('department', isEqualTo: department);
      }

      final querySnapshot = await query.get().timeout(_timeoutDuration);

      List<StudentSearchResult> results = [];

      for (var doc in querySnapshot.docs) {
        final userData = UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

        // Filter by skill if specified
        if (skill != null && skill.isNotEmpty && skill != 'tümü') {
          if (userData.skills == null ||
              !userData.skills!.any((s) => s.toLowerCase().contains(skill.toLowerCase()))) {
            continue;
          }
        }

        // Filter by search query (name, university, etc.)
        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final queryLower = searchQuery.toLowerCase();
          final matchesName = userData.name.toLowerCase().contains(queryLower);
          final matchesUniversity = (userData.university ?? '').toLowerCase().contains(queryLower);
          final matchesDepartment = (userData.department ?? '').toLowerCase().contains(queryLower);
          
          if (!matchesName && !matchesUniversity && !matchesDepartment) {
            continue;
          }
        }

        // Get student projects
        List<ProjectModel> projects = [];
        if (projectType != null && projectType.isNotEmpty && projectType != 'tümü') {
          // Filter projects by type
          final allProjects = await _projectService.getAllProjects(projectType: projectType);
          projects = allProjects.where((p) => p.userId == doc.id).toList();
          
          // If project type filter is specified and student has no matching projects, skip
          if (projects.isEmpty) {
            continue;
          }
        } else {
          // Get all projects for this student
          projects = await _projectService.getStudentProjects(doc.id);
        }

        results.add(StudentSearchResult(
          student: userData,
          projects: projects,
        ));
      }

      return results;
    } catch (e) {
      print('Öğrenci arama hatası: $e');
      return [];
    }
  }

  // Get unique departments list for filter dropdown
  Future<List<String>> getUniqueDepartments() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'ogrenci')
          .where('status', isEqualTo: 'active')
          .get()
          .timeout(_timeoutDuration);

      final departments = <String>{};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final dept = data['department']?.toString();
        if (dept != null && dept.trim().isNotEmpty) {
          departments.add(dept.trim());
        }
      }

      return departments.toList()..sort();
    } catch (e) {
      print('Bölüm listesi hatası: $e');
      return [];
    }
  }

  // Get unique skills list for filter dropdown
  Future<List<String>> getUniqueSkills() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'ogrenci')
          .where('status', isEqualTo: 'active')
          .get()
          .timeout(_timeoutDuration);

      final skills = <String>{};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final skillsList = data['skills'];
        if (skillsList is List) {
          for (var skill in skillsList) {
            if (skill is String && skill.trim().isNotEmpty) {
              skills.add(skill.trim());
            }
          }
        }
      }

      return skills.toList()..sort();
    } catch (e) {
      print('Yetenek listesi hatası: $e');
      return [];
    }
  }
}

// Result model for search
class StudentSearchResult {
  final UserModel student;
  final List<ProjectModel> projects;

  StudentSearchResult({
    required this.student,
    required this.projects,
  });
}

