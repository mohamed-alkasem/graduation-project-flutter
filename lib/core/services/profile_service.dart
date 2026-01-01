// lib/core/services/profile_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const Duration _timeoutDuration = Duration(seconds: 10);

  // Get profile by user ID
  Future<ProfileModel?> getProfileByUserId(String userId) async {
    try {
      // First try to get from users collection
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get()
          .timeout(_timeoutDuration);

      if (!userDoc.exists) {
        return null;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Get additional data based on role
      Map<String, dynamic>? additionalData;

      if (userData['role'] == 'ogrenci') {
        DocumentSnapshot studentDoc = await _firestore
            .collection('students')
            .doc(userId)
            .get()
            .timeout(_timeoutDuration);

        if (studentDoc.exists) {
          additionalData = studentDoc.data() as Map<String, dynamic>;
        }
      } else if (userData['role'] == 'sirket') {
        DocumentSnapshot companyDoc = await _firestore
            .collection('companies')
            .doc(userId)
            .get()
            .timeout(_timeoutDuration);

        if (companyDoc.exists) {
          additionalData = companyDoc.data() as Map<String, dynamic>;
        }
      }

      // Combine data
      Map<String, dynamic> combinedData = {
        ...userData,
        ...?additionalData,
        'userId': userId,
      };

      return ProfileModel.fromMap(combinedData, userId);
    } catch (e) {
      print('Profil getirme hatası: $e');
      return null;
    }
  }

  // Update profile
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      final userId = profile.userId;

      // Update users collection
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'name': profile.name,
        'email': profile.email,
        'updatedAt': FieldValue.serverTimestamp(),
      })
          .timeout(_timeoutDuration);

      // Update role-specific collection
      if (profile.isStudent) {
        await _firestore
            .collection('students')
            .doc(userId)
            .update({
          'name': profile.name,
          'studentNo': profile.studentNo,
          'university': profile.university,
          'department': profile.department,
          'phone': profile.phone,
          'skills': profile.skills,
          'about': profile.about,
          'profileImageUrl': profile.profileImageUrl,
          'githubUrl': profile.githubUrl,
          'linkedinUrl': profile.linkedinUrl,
          'portfolioUrl': profile.portfolioUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        })
            .timeout(_timeoutDuration);
      } else if (profile.isCompany) {
        await _firestore
            .collection('companies')
            .doc(userId)
            .update({
          'companyName': profile.companyName,
          'contactPerson': profile.name,
          'phone': profile.companyPhone,
          'sector': profile.sector,
          'address': profile.address,
          'website': profile.website,
          'taxNo': profile.taxNo,
          'companyLogoUrl': profile.companyLogoUrl,
          'companyDescription': profile.companyDescription,
          'companySize': profile.companySize,
          'updatedAt': FieldValue.serverTimestamp(),
        })
            .timeout(_timeoutDuration);
      }
    } catch (e) {
      print('Profil güncelleme hatası: $e');
      throw Exception('Profil güncelleme başarısız: ${e.toString()}');
    }
  }

  // Update profile image
  Future<void> updateProfileImage(String userId, String imageUrl, bool isStudent) async {
    try {
      final collection = isStudent ? 'students' : 'companies';
      final field = isStudent ? 'profileImageUrl' : 'companyLogoUrl';

      await _firestore
          .collection(collection)
          .doc(userId)
          .update({
        field: imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      })
          .timeout(_timeoutDuration);
    } catch (e) {
      print('Profil resmi güncelleme hatası: $e');
      throw Exception('Profil resmi güncelleme başarısız');
    }
  }

  // Stream profile changes
  Stream<ProfileModel?> profileStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((userSnapshot) async {
      if (!userSnapshot.exists) return null;

      final userData = userSnapshot.data() as Map<String, dynamic>;
      final role = userData['role'] as String? ?? '';

      Map<String, dynamic>? additionalData;

      if (role == 'ogrenci') {
        final studentSnapshot = await _firestore
            .collection('students')
            .doc(userId)
            .get();

        if (studentSnapshot.exists) {
          additionalData = studentSnapshot.data() as Map<String, dynamic>;
        }
      } else if (role == 'sirket') {
        final companySnapshot = await _firestore
            .collection('companies')
            .doc(userId)
            .get();

        if (companySnapshot.exists) {
          additionalData = companySnapshot.data() as Map<String, dynamic>;
        }
      }

      final combinedData = {
        ...userData,
        ...?additionalData,
        'userId': userId,
      };

      return ProfileModel.fromMap(combinedData, userId);
    });
  }
}