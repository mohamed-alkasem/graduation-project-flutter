// lib/core/services/internship_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/internship_request_model.dart';
import 'notification_service.dart';
import '../models/notification_model.dart';

class InternshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  static const Duration _timeoutDuration = Duration(seconds: 15);

  // Add internship request
  Future<String> addInternshipRequest(InternshipRequestModel request) async {
    try {
      final docRef = await _firestore
          .collection('internship_requests')
          .add(request.toMap(isUpdate: false))
          .timeout(_timeoutDuration);
      
      return docRef.id;
    } catch (e) {
      print('Staj ilanı ekleme hatası: $e');
      throw Exception('Staj ilanı eklenemedi: ${e.toString()}');
    }
  }

  // Update internship request
  Future<void> updateInternshipRequest(InternshipRequestModel request) async {
    if (request.id == null) {
      throw Exception('Staj ilanı ID bulunamadı');
    }

    try {
      await _firestore
          .collection('internship_requests')
          .doc(request.id)
          .update(request.toMap(isUpdate: true))
          .timeout(_timeoutDuration);
    } catch (e) {
      print('Staj ilanı güncelleme hatası: $e');
      throw Exception('Staj ilanı güncellenemedi: ${e.toString()}');
    }
  }

  // Delete internship request
  Future<void> deleteInternshipRequest(String requestId) async {
    try {
      await _firestore
          .collection('internship_requests')
          .doc(requestId)
          .delete()
          .timeout(_timeoutDuration);
    } catch (e) {
      print('Staj ilanı silme hatası: $e');
      throw Exception('Staj ilanı silinemedi: ${e.toString()}');
    }
  }

  // Get all active internship requests (for students)
  Future<List<InternshipRequestModel>> getActiveInternshipRequests({String? category}) async {
    try {
      Query query = _firestore
          .collection('internship_requests')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (category != null && category.isNotEmpty && category != 'tümü') {
        query = query.where('category', isEqualTo: category);
      }

      final querySnapshot = await query.get().timeout(_timeoutDuration);

      return querySnapshot.docs
          .map((doc) => InternshipRequestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((request) => request.isOpen)
          .toList();
    } catch (e) {
      print('Staj ilanları getirme hatası: $e');
      return [];
    }
  }

  // Get internship requests by company
  Future<List<InternshipRequestModel>> getCompanyInternshipRequests(String companyId) async {
    try {
      final querySnapshot = await _firestore
          .collection('internship_requests')
          .where('companyId', isEqualTo: companyId)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(_timeoutDuration);

      return querySnapshot.docs
          .map((doc) => InternshipRequestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Şirket staj ilanları getirme hatası: $e');
      return [];
    }
  }

  // Stream internship requests by company (for real-time updates)
  Stream<List<InternshipRequestModel>> streamCompanyInternshipRequests(String companyId) {
    return _firestore
        .collection('internship_requests')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InternshipRequestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Stream active internship requests (for students)
  Stream<List<InternshipRequestModel>> streamActiveInternshipRequests({String? category}) {
    try {
      Query query;
      
      if (category != null && category.isNotEmpty && category != 'tümü') {
        // Use composite index: isActive + category + createdAt
        query = _firestore
            .collection('internship_requests')
            .where('isActive', isEqualTo: true)
            .where('category', isEqualTo: category)
            .orderBy('createdAt', descending: true);
      } else {
        // Use simple index: isActive + createdAt
        query = _firestore
            .collection('internship_requests')
            .where('isActive', isEqualTo: true)
            .orderBy('createdAt', descending: true);
      }

      return query.snapshots().asyncMap((snapshot) async {
        try {
          final requests = <InternshipRequestModel>[];
          
          for (var doc in snapshot.docs) {
            try {
              final request = InternshipRequestModel.fromMap(
                doc.data() as Map<String, dynamic>, 
                doc.id
              );
              if (request.isOpen) {
                requests.add(request);
              }
            } catch (e) {
              print('Staj ilanı parse hatası (doc ${doc.id}): $e');
              // Continue with next document
            }
          }
          
          return requests;
        } catch (e) {
          print('Staj ilanları map hatası: $e');
          return <InternshipRequestModel>[];
        }
      });
    } catch (e) {
      print('Staj ilanları query oluşturma hatası: $e');
      // Return empty stream on error
      return Stream.value(<InternshipRequestModel>[]);
    }
  }

  // Get internship request by ID
  Future<InternshipRequestModel?> getInternshipRequestById(String requestId) async {
    try {
      final doc = await _firestore
          .collection('internship_requests')
          .doc(requestId)
          .get()
          .timeout(_timeoutDuration);

      if (!doc.exists) return null;

      return InternshipRequestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('Staj ilanı getirme hatası: $e');
      return null;
    }
  }

  // Apply for internship
  Future<String> applyForInternship(InternshipApplicationModel application) async {
    try {
      // Check if already applied
      final existingApps = await _firestore
          .collection('internship_applications')
          .where('internshipRequestId', isEqualTo: application.internshipRequestId)
          .where('studentId', isEqualTo: application.studentId)
          .get()
          .timeout(_timeoutDuration);

      if (existingApps.docs.isNotEmpty) {
        throw Exception('Bu staj ilanına zaten başvurdunuz');
      }

      final docRef = await _firestore
          .collection('internship_applications')
          .add(application.toMap(isUpdate: false))
          .timeout(_timeoutDuration);
      
      return docRef.id;
    } catch (e) {
      print('Başvuru ekleme hatası: $e');
      throw Exception('Başvuru yapılamadı: ${e.toString()}');
    }
  }

  // Get student applications
  Future<List<InternshipApplicationModel>> getStudentApplications(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('internship_applications')
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(_timeoutDuration);

      return querySnapshot.docs
          .map((doc) => InternshipApplicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Öğrenci başvuruları getirme hatası: $e');
      return [];
    }
  }

  // Get applications for a specific internship request
  Future<List<InternshipApplicationModel>> getApplicationsForRequest(String requestId) async {
    try {
      final querySnapshot = await _firestore
          .collection('internship_applications')
          .where('internshipRequestId', isEqualTo: requestId)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(_timeoutDuration);

      return querySnapshot.docs
          .map((doc) => InternshipApplicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Başvurular getirme hatası: $e');
      return [];
    }
  }

  // Update application status
  Future<void> updateApplicationStatus(String applicationId, String status) async {
    try {
      // Get application to send notification
      final appDoc = await _firestore
          .collection('internship_applications')
          .doc(applicationId)
          .get()
          .timeout(_timeoutDuration);

      if (!appDoc.exists) {
        throw Exception('Başvuru bulunamadı');
      }

      final appData = appDoc.data() as Map<String, dynamic>;
      final studentId = appData['studentId']?.toString() ?? '';
      final studentName = appData['studentName']?.toString() ?? '';
      final requestId = appData['internshipRequestId']?.toString() ?? '';

      // Get internship request for title
      String requestTitle = 'Staj İlanı';
      if (requestId.isNotEmpty) {
        final requestDoc = await _firestore
            .collection('internship_requests')
            .doc(requestId)
            .get()
            .timeout(_timeoutDuration);
        if (requestDoc.exists) {
          requestTitle = requestDoc.data()?['title']?.toString() ?? requestTitle;
        }
      }

      // Update status
      await _firestore
          .collection('internship_applications')
          .doc(applicationId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(_timeoutDuration);

      // Send notification to student
      if (studentId.isNotEmpty) {
        final statusText = status == 'accepted' ? 'kabul edildi' : 'reddedildi';
        String companyId = '';
        String companyName = 'Şirket';
        
        // Get company info from request
        if (requestId.isNotEmpty) {
          try {
            final requestDoc = await _firestore
                .collection('internship_requests')
                .doc(requestId)
                .get()
                .timeout(_timeoutDuration);
            if (requestDoc.exists) {
              final reqData = requestDoc.data();
              companyId = reqData?['companyId']?.toString() ?? '';
              companyName = reqData?['companyName']?.toString() ?? companyName;
            }
          } catch (e) {
            print('Şirket bilgisi alınamadı: $e');
          }
        }

        final notification = NotificationModel(
          recipientId: studentId,
          senderId: companyId,
          senderName: companyName,
          title: 'Staj Başvurunuz $statusText',
          message: '$requestTitle için başvurunuz $statusText.',
          type: 'application_status',
          createdAt: DateTime.now(),
        );

        try {
          await _notificationService.sendNotification(notification);
        } catch (e) {
          print('Bildirim gönderilemedi: $e');
          // Don't throw, status update is more important
        }
      }
    } catch (e) {
      print('Başvuru durumu güncelleme hatası: $e');
      throw Exception('Başvuru durumu güncellenemedi: ${e.toString()}');
    }
  }

  // Check if student already applied
  Future<bool> hasStudentApplied(String requestId, String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('internship_applications')
          .where('internshipRequestId', isEqualTo: requestId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get()
          .timeout(_timeoutDuration);

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

