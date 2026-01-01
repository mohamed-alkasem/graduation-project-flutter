// lib/core/firebase/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image
  Future<String> uploadProfileImage(
      File imageFile,
      String userId,
      bool isStudent,
      ) async {
    try {
      final fileName = basename(imageFile.path);
      final destination = isStudent
          ? 'students/$userId/profile_images/$fileName'
          : 'companies/$userId/logos/$fileName';

      final ref = _storage.ref().child(destination);
      await ref.putFile(imageFile);

      return await ref.getDownloadURL();
    } catch (e) {
      print('Image upload error: $e');
      throw Exception('Resim yükleme başarısız: ${e.toString()}');
    }
  }

  // Upload portfolio file
  Future<String> uploadPortfolioFile(File file, String userId, String fileName) async {
    try {
      final destination = 'students/$userId/portfolio/$fileName';
      final ref = _storage.ref().child(destination);
      await ref.putFile(file);

      return await ref.getDownloadURL();
    } catch (e) {
      print('File upload error: $e');
      throw Exception('Dosya yükleme başarısız');
    }
  }

  // Upload internship application file
  Future<String> uploadInternshipFile(File file, String userId, String requestId, String documentType) async {
    try {
      final fileName = basename(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destination = 'students/$userId/internships/$requestId/$documentType/$timestamp$fileName';
      final ref = _storage.ref().child(destination);
      await ref.putFile(file);

      return await ref.getDownloadURL();
    } catch (e) {
      print('Internship file upload error: $e');
      throw Exception('Dosya yükleme başarısız: ${e.toString()}');
    }
  }

  // Upload project image
  Future<String> uploadProjectImage(File imageFile, String userId, String projectId) async {
    try {
      final fileName = basename(imageFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destination = 'students/$userId/projects/$projectId/$timestamp$fileName';

      final ref = _storage.ref().child(destination);
      await ref.putFile(imageFile);

      return await ref.getDownloadURL();
    } catch (e) {
      print('Project image upload error: $e');
      throw Exception('Proje resmi yükleme başarısız: ${e.toString()}');
    }
  }

  // Delete file
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('File delete error: $e');
      throw Exception('Dosya silme başarısız');
    }
  }
}