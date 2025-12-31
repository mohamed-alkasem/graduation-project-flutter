// lib/core/firebase/auth_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Timeout süresi
  static const Duration _timeoutDuration = Duration(seconds: 15);

  // Kayıt ol - Öğrenci (مصحح)
  Future<UserModel?> registerStudent({
    required String email,
    required String password,
    required String name,
    required String studentNo,
    required String university,
    required String department,
    String? phone,
    List<String>? skills,
  }) async {
    try {
      print('Öğrenci kaydı başlıyor: $email');

      // 1. Firebase Authentication ile kullanıcı oluştur
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      )
          .timeout(_timeoutDuration);

      final userId = userCredential.user!.uid;
      print('Firebase Auth başarılı, User ID: $userId');

      // 2. Kullanıcı bilgilerini Firestore'a kaydet
      UserModel userModel = UserModel(
        id: userId,
        email: email.trim(),
        name: name.trim(),
        role: 'ogrenci',
        createdAt: DateTime.now(),
        studentNo: studentNo.trim(),
        university: university.trim(),
        department: department.trim(),
        phone: phone?.trim(),
        skills: skills ?? [],
      );

      print('UserModel oluşturuldu, Firestore kaydı başlıyor...');

      // فقط users koleksiyonuna kaydet - احذف students مؤقتاً
      await _firestore
          .collection('users')
          .doc(userId)
          .set(userModel.toMap())
          .timeout(_timeoutDuration);

      print('✅ Öğrenci kaydı başarılı! Kullanıcı users koleksiyonuna kaydedildi.');

      return userModel;

    } on TimeoutException {
      print('❌ Öğrenci kaydı timeout!');
      throw Exception('İşlem zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      if (e.code == 'weak-password') {
        throw Exception('Şifre çok zayıf. En az 6 karakter olmalı.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Bu e-posta adresi zaten kullanımda.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Geçersiz e-posta adresi.');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('E-posta/şifre ile giriş etkin değil.');
      } else {
        throw Exception('Kayıt başarısız: ${e.message}');
      }
    } on FirebaseException catch (e) {
      print('Firestore Exception: ${e.code} - ${e.message}');
      throw Exception('Veritabanı hatası: ${e.message}');
    } catch (e, stackTrace) {
      print('Genel Exception: $e');
      print('Stack Trace: $stackTrace');
      throw Exception('Kayıt sırasında beklenmeyen bir hata oluştu: ${e.toString()}');
    }
  }

  // Kayıt ol - Şirket (مصحح)
  Future<UserModel?> registerCompany({
    required String email,
    required String password,
    required String companyName,
    required String contactPerson,
    required String phone,
    required String sector,
    required String address,
    String? website,
    String? taxNo,
  }) async {
    try {
      print('Şirket kaydı başlıyor: $email');

      // 1. Firebase Authentication ile kullanıcı oluştur
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      )
          .timeout(_timeoutDuration);

      final userId = userCredential.user!.uid;
      print('Firebase Auth başarılı, User ID: $userId');

      // 2. Kullanıcı bilgilerini Firestore'a kaydet
      UserModel userModel = UserModel(
        id: userId,
        email: email.trim(),
        name: contactPerson.trim(),
        role: 'sirket',
        createdAt: DateTime.now(),
        companyName: companyName.trim(),
        sector: sector.trim(),
        companyPhone: phone.trim(),
        website: website?.trim(),
        address: address.trim(),
      );

      print('UserModel oluşturuldu, Firestore kaydı başlıyor...');

      // فقط users koleksiyonuna kaydet - احذف companies مؤقتاً
      await _firestore
          .collection('users')
          .doc(userId)
          .set(userModel.toMap())
          .timeout(_timeoutDuration);

      print('✅ Şirket kaydı başarılı! Kullanıcı users koleksiyonuna kaydedildi.');

      return userModel;

    } on TimeoutException {
      print('❌ Şirket kaydı timeout!');
      throw Exception('İşlem zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin.');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      if (e.code == 'weak-password') {
        throw Exception('Şifre çok zayıf. En az 8 karakter olmalı.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Bu e-posta adresi zaten kullanımda.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Geçersiz e-posta adresi.');
      } else {
        throw Exception('Kayıt başarısız: ${e.message}');
      }
    } catch (e) {
      print('Genel Exception: $e');
      throw Exception('Kayıt sırasında hata oluştu: ${e.toString()}');
    }
  }

  // Giriş yap (مصحح)
  // Giriş yap (مبسط - بدون Firestore تحقق أول)
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('Giriş denemesi: $email');

      // 1. فقط Firebase Authentication ile giriş yap
      UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      )
          .timeout(_timeoutDuration);

      final userId = userCredential.user!.uid;
      print('✅ Firebase Auth başarılı, User ID: $userId');

      // 2. مباشرة أنشئ UserModel من بيانات Auth فقط
      UserModel userModel = UserModel(
        id: userId,
        email: email.trim(),
        name: userCredential.user!.displayName ?? 'Kullanıcı',
        role: 'ogrenci', // افتراضي - يمكن تعديله لاحقاً
        createdAt: DateTime.now(),
      );

      print('✅ Giriş başarılı! UserModel oluşturuldu');
      return userModel;

    } on TimeoutException {
      print('❌ Giriş timeout!');
      throw Exception('Giriş işlemi zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found') {
        throw Exception('Bu e-posta ile kayıtlı kullanıcı bulunamadı.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Hatalı şifre.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Geçersiz e-posta formatı.');
      } else if (e.code == 'user-disabled') {
        throw Exception('Bu hesap devre dışı bırakıldı.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin.');
      } else if (e.code == 'network-request-failed') {
        throw Exception('Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin.');
      } else {
        throw Exception('Giriş sırasında hata oluştu: ${e.message}');
      }
    } catch (e) {
      print('Genel Exception: $e');
      throw Exception('Giriş sırasında hata oluştu: ${e.toString()}');
    }
  }

  // Çıkış yap
  Future<void> logout() async {
    try {
      print('Çıkış yapılıyor...');
      await _auth.signOut();
      print('✅ Çıkış başarılı');
    } catch (e) {
      print('Çıkış hatası: $e');
      throw Exception('Çıkış sırasında hata oluştu: ${e.toString()}');
    }
  }

  // Kullanıcı bilgilerini getir
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get()
          .timeout(_timeoutDuration);

      if (userDoc.exists) {
        print('✅ Kullanıcı bilgileri başarıyla alındı');
        return UserModel.fromMap(
          userDoc.data() as Map<String, dynamic>,
          userId,
        );
      }
      print('⚠️ Kullanıcı bulunamadı: $userId');
      return null;
    } catch (e) {
      print('❌ Kullanıcı bilgileri alınamadı: $e');
      return null;
    }
  }

  // Öğrenci verilerini getir - مؤقتاً معلق
  Future<Map<String, dynamic>?> getStudentData(String userId) async {
    try {
      // أولاً تحقق من وجود collection
      final collectionExists = await _checkCollectionExists('students');
      if (!collectionExists) {
        print('⚠️ Students koleksiyonu mevcut değil');
        return null;
      }

      DocumentSnapshot studentDoc = await _firestore
          .collection('students')
          .doc(userId)
          .get()
          .timeout(_timeoutDuration);

      return studentDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Öğrenci verileri alınamadı: $e');
      return null;
    }
  }

  // Şirket verilerini getir - مؤقتاً معلق
  Future<Map<String, dynamic>?> getCompanyData(String userId) async {
    try {
      // أولاً تحقق من وجود collection
      final collectionExists = await _checkCollectionExists('companies');
      if (!collectionExists) {
        print('⚠️ Companies koleksiyonu mevcut değil');
        return null;
      }

      DocumentSnapshot companyDoc = await _firestore
          .collection('companies')
          .doc(userId)
          .get()
          .timeout(_timeoutDuration);

      return companyDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Şirket verileri alınamadı: $e');
      return null;
    }
  }

  // Yardımcı fonksiyon: Collection var mı kontrol et
  Future<bool> _checkCollectionExists(String collectionName) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('$collectionName kontrol hatası: $e');
      return false;
    }
  }

  // Şifre sıfırlama
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      print('✅ Şifre sıfırlama e-postası gönderildi');
    } catch (e) {
      print('❌ Şifre sıfırlama hatası: $e');
      throw Exception('Şifre sıfırlama hatası: ${e.toString()}');
    }
  }

  // Mevcut kullanıcıyı kontrol et
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Kullanıcı durumunu dinle
  Stream<User?> get userState {
    return _auth.authStateChanges();
  }

  // Kullanıcı durumunu kontrol et
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // Kullanıcı ID'sini al
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Firestore bağlantı testi
  Future<bool> testFirestoreConnection() async {
    try {
      await _firestore
          .collection('users')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      print('✅ Firestore bağlantısı başarılı');
      return true;
    } catch (e) {
      print('❌ Firestore bağlantısı başarısız: $e');
      return false;
    }
  }
}