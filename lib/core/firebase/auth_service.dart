// lib/core/firebase/auth_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const Duration _timeoutDuration = Duration(seconds: 15);

  // ===== Email verification (اختياري) =====
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  bool isEmailVerified() => _auth.currentUser?.emailVerified ?? false;

  // ===== Helpers =====
  User? getCurrentUser() => _auth.currentUser;
  String? getCurrentUid() => _auth.currentUser?.uid;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(String uid) async {
    return _firestore.collection('users').doc(uid).get().timeout(_timeoutDuration);
  }

  // ===== Register Student =====
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
      final userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      )
          .timeout(_timeoutDuration);

      final userId = userCredential.user!.uid;

      final userModel = UserModel(
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
        status: 'active',
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .set(userModel.toMap(isUpdate: false), SetOptions(merge: true))
          .timeout(_timeoutDuration);

      return userModel;
    } on TimeoutException {
      throw Exception('İşlem zaman aşımına uğradı.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Şifre çok zayıf. En az 6 karakter olmalı.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Bu e-posta adresi zaten kullanımda.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Geçersiz e-posta adresi.');
      }
      throw Exception('Kayıt başarısız: ${e.message}');
    } catch (e) {
      throw Exception('Kayıt sırasında hata oluştu: $e');
    }
  }

  // ===== Register Company =====
  // ===== Register Company =====
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
      final userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      )
          .timeout(_timeoutDuration);

      final userId = userCredential.user!.uid;

      // ✅ 1) users collection (أساسي فقط)
      final userModel = UserModel(
        id: userId,
        email: email.trim(),
        name: contactPerson.trim(), // نخزن contactPerson داخل name
        role: 'sirket',
        createdAt: DateTime.now(),
        companyName: companyName.trim(),
        sector: sector.trim(),
        companyPhone: phone.trim(),
        website: website?.trim(),
        address: address.trim(),
        companyDescription: null,
        status: 'active',
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .set(userModel.toMap(isUpdate: false), SetOptions(merge: true))
          .timeout(_timeoutDuration);

      // ✅ 2) profiles collection (تفاصيل الشركة)
      final profileData = _cleanData({
        'userId': userId,
        'email': email.trim(),
        'name': contactPerson.trim(),
        'role': 'sirket',
        'companyName': companyName.trim(),
        'contactPerson': contactPerson.trim(),
        'companyPhone': phone.trim(),
        'sector': sector.trim(),
        'address': address.trim(),
        'website': website?.trim(),
        'taxNo': taxNo?.trim(),
        'status': 'pending', // أو active حسب نظامك
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection('profiles')
          .doc(userId) // ✅ نفس uid
          .set(profileData, SetOptions(merge: true))
          .timeout(_timeoutDuration);

      return userModel;
    } on TimeoutException {
      throw Exception('İşlem zaman aşımına uğradı.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Şifre çok zayıf. En az 8 karakter olmalı.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Bu e-posta adresi zaten kullanımda.');
      }
      throw Exception('Kayıt başarısız: ${e.message}');
    } catch (e) {
      throw Exception('Kayıt sırasında hata oluştu: $e');
    }
  }


  // ===== Login =====
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth
          .signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      )
          .timeout(_timeoutDuration);

      final u = userCredential.user;
      if (u == null) return null;

      // ✅ أهم تعديل: بعد تسجيل الدخول جيب بياناته من Firestore
      final data = await getUserData(u.uid);
      if (data != null) return data;

      // fallback
      return UserModel(
        id: u.uid,
        email: u.email ?? email.trim(),
        name: u.displayName ?? 'Kullanıcı',
        role: '',
        createdAt: DateTime.now(),
      );
    } on TimeoutException {
      throw Exception('Giriş işlemi zaman aşımına uğradı.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Bu e-posta ile kayıtlı kullanıcı bulunamadı.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Hatalı şifre.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Geçersiz e-posta formatı.');
      } else if (e.code == 'user-disabled') {
        throw Exception('Bu hesap devre dışı bırakıldı.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Çok fazla deneme yaptınız. Daha sonra tekrar deneyin.');
      } else if (e.code == 'network-request-failed') {
        throw Exception('Ağ bağlantısı hatası.');
      }
      throw Exception('Giriş sırasında hata oluştu: ${e.message}');
    }
  }

  Future<void> logout() async => _auth.signOut();

  // ===== Password Reset =====
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      ).timeout(_timeoutDuration);
    } on TimeoutException {
      throw Exception('İşlem zaman aşımına uğradı.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Geçersiz e-posta formatı.');
      }
      throw Exception('Şifre sıfırlama e-postası gönderilemedi: ${e.message}');
    } catch (e) {
      throw Exception('Şifre sıfırlama işlemi başarısız: ${e.toString()}');
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get()
          .timeout(_timeoutDuration);

      if (!doc.exists) return null;

      return UserModel.fromMap(doc.data() as Map<String, dynamic>, userId);
    } catch (_) {
      return null;
    }
  }

  // ===== Update Student Profile =====
  Future<void> updateStudentProfile({
    required String userId,
    required String name,
    required String university,
    required String department,
    required String studentNo,
    String? phone,
    List<String>? skills,
    String? bio,
    String? grade,
    List<String>? hobbies,
  }) async {
    final updateData = _cleanData({
      'name': name,
      'university': university,
      'department': department,
      'studentNo': studentNo,
      'phone': phone,
      'skills': skills ?? [],
      'bio': bio,
      'grade': grade,
      'hobbies': hobbies ?? [],
      'role': 'ogrenci',
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('users')
        .doc(userId)
        .set(updateData, SetOptions(merge: true))
        .timeout(_timeoutDuration);
  }

  // ✅ تحديث صورة الطالب (اختياري بس مفيد)
  Future<void> updateStudentProfileImage({
    required String userId,
    required String imageUrl,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'profileImageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).timeout(_timeoutDuration);
  }

  // ===== Update Company Profile =====
  Future<void> updateCompanyProfile({
    required String userId,
    required String companyName,
    required String contactPerson,
    required String sector,
    required String address,
    required String phone,
    String? website,
    String? companyDescription,
    String? taxNo,
    String? companySize,
  }) async {
    // 1) users (أساسي)
    final usersUpdate = _cleanData({
      'companyName': companyName,
      'name': contactPerson, // ✅ contact person عندك مخزن بـ name
      'sector': sector,
      'address': address,
      'companyPhone': phone,
      'website': website,
      'companyDescription': companyDescription,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('users')
        .doc(userId)
        .set(usersUpdate, SetOptions(merge: true))
        .timeout(_timeoutDuration);

    // 2) profiles (تفاصيل + status/admin fields لا تلمسها)
    final profileUpdate = _cleanData({
      'userId': userId,
      'role': 'sirket',
      'companyName': companyName,
      'contactPerson': contactPerson,
      'sector': sector,
      'address': address,
      'companyPhone': phone,
      'website': website,
      'companyDescription': companyDescription,
      'taxNo': taxNo,
      'companySize': companySize,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // ✅ نستخدم نفس docId = userId (أفضل توحيداً)
    await _firestore
        .collection('profiles')
        .doc(userId)
        .set(profileUpdate, SetOptions(merge: true))
        .timeout(_timeoutDuration);
  }


  // ✅ تحديث شعار الشركة داخل users
  Future<void> updateCompanyLogo({
    required String userId,
    required String logoUrl,
  }) async {
    // users (اختياري)
    await _firestore.collection('users').doc(userId).set({
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).timeout(_timeoutDuration);

    // profiles (المكان الصحيح)
    await _firestore.collection('profiles').doc(userId).set({
      'companyLogoUrl': logoUrl.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).timeout(_timeoutDuration);
  }

  Future<void> updateCompanySize({
    required String userId,
    required String companySize,
  }) async {
    await _firestore.collection('profiles').doc(userId).set({
      'companySize': companySize.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).timeout(_timeoutDuration);
  }


  // ===== Utils =====
  Map<String, dynamic> _cleanData(Map<String, dynamic?> data) {
    final cleaned = <String, dynamic>{};
    data.forEach((key, value) {
      if (value == null) return;
      if (value is String) {
        final v = value.trim();
        if (v.isEmpty) return;
        cleaned[key] = v;
      } else if (value is List) {
        if (value.isEmpty) return;
        cleaned[key] = value;
      } else {
        cleaned[key] = value;
      }
    });
    return cleaned;
  }
}
