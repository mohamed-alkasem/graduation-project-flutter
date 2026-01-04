// lib/screens/auth/ogrenci/ogrenci_register.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bitirmetezimobil/widgets/custom_text_field.dart';
import 'package:bitirmetezimobil/widgets/gradient_button.dart';
import '../../../screens/auth/ogrenci/ogrenci_login.dart';

class OgrenciRegister extends StatefulWidget {
  const OgrenciRegister({super.key});

  @override
  _OgrenciRegisterState createState() => _OgrenciRegisterState();
}

class _OgrenciRegisterState extends State<OgrenciRegister> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentNoController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Öğrenci Kayıt',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // For balance
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Üniversite öğrencisi olarak portföyünüzü oluşturmak için kaydolun',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 30),

              // Form
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Kişisel Bilgiler
                        const Text(
                          '📝 Kişisel Bilgiler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          controller: _nameController,
                          label: 'Ad Soyad',
                          prefixIcon: Icons.person,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen adınızı soyadınızı girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _emailController,
                          label: 'E-posta Adresi',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen e-posta adresinizi girin';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Geçerli bir e-posta adresi girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Üniversite Bilgileri
                        const Text(
                          '🎓 Üniversite Bilgileri',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _studentNoController,
                                label: 'Öğrenci No',
                                prefixIcon: Icons.numbers,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _phoneController,
                                label: 'Telefon',
                                prefixIcon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                                      return 'Geçerli bir telefon numarası girin';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _universityController,
                          label: 'Üniversite',
                          prefixIcon: Icons.school,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen üniversitenizi girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _departmentController,
                          label: 'Bölüm',
                          prefixIcon: Icons.menu_book,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen bölümünüzü girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _skillsController,
                          label: 'Yetenekler (virgülle ayırın)',
                          prefixIcon: Icons.code,
                          maxLines: 3,
                        ),

                        // Güvenlik Bilgileri
                        const SizedBox(height: 30),
                        const Text(
                          '🔒 Güvenlik Bilgileri',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          controller: _passwordController,
                          label: 'Şifre',
                          prefixIcon: Icons.lock,
                          obscureText: _obscurePassword,
                          isPassword: true,
                          isRequired: true,
                          onToggleVisibility: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen şifrenizi girin';
                            }
                            if (value.length < 6) {
                              return 'Şifre en az 6 karakter olmalıdır';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _confirmController,
                          label: 'Şifreyi Onayla',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirm,
                          isPassword: true,
                          isRequired: true,
                          onToggleVisibility: () {
                            setState(() => _obscureConfirm = !_obscureConfirm);
                          },
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Şifreler eşleşmiyor';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        // Kayıt Butonu
                        GradientButton(
                          text: 'HESAP OLUŞTUR',
                          onPressed: _registerStudent,
                          isLoading: _isLoading,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1ABC9C), Color(0xFF16A085)],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Zaten Hesabı Var
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Zaten hesabınız var mı? '),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OgrenciLogin(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  color: Color(0xFF1ABC9C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        print('🎯 Öğrenci kaydı başlıyor...');

        // 1. Firebase Authentication - فقط هذه الخطوة أول
        final UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final User user = userCredential.user!;
        print('✅ Firebase Auth başarılı, User ID: ${user.uid}');

        // 2. إظهار رسالة نجاح فورية
        _showSuccessDialog();

        // 3. Firestore kaydı - في الخلفية (async)
        _saveToFirestoreInBackground(user);

        // 4. Email verification - في الخلفية
        _sendVerificationEmailInBackground(user);

      } on FirebaseAuthException catch (e) {
        // نفس كود معالجة الأخطاء...
      } catch (e) {
        // نفس كود معالجة الأخطاء...
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

// Firestore kaydı - في الخلفية
  void _saveToFirestoreInBackground(User user) async {
    try {
      final userData = {
        'uid': user.uid,
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'studentNo': _studentNoController.text.trim(),
        'university': _universityController.text.trim(),
        'department': _departmentController.text.trim(),
        'phone': _phoneController.text.trim(),
        'skills': _skillsController.text.isNotEmpty
            ? _skillsController.text.split(',').map((e) => e.trim()).toList()
            : [],
        'userType': 'ogrenci',
        'role': 'ogrenci',
        'score': 0,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // محاولة بدون timeout
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData);

      print('✅ Firestore kaydı arka planda başarılı!');
    } catch (e) {
      print('⚠️ Firestore arka plan hatası: $e');
      // ما نرمي exception هنا عشان ما يؤثر على المستخدم
    }
  }

// Email verification - في الخلفية
  void _sendVerificationEmailInBackground(User user) async {
    try {
      await user.sendEmailVerification();
      print('✅ Email doğrulama gönderildi');
    } catch (e) {
      print('⚠️ Email doğrulama hatası: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('🎉 Kayıt Başarılı!'),
          ],
        ),
        content: const Text(
          'Hesabınız başarıyla oluşturuldu. '
              'E-posta adresinize doğrulama linki gönderildi. '
              'Lütfen e-postanızı kontrol edin ve hesabınızı doğrulayın.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog'u kapat
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const OgrenciLogin(),
                ),
              );
            },
            child: const Text(
              'Giriş Sayfasına Git',
              style: TextStyle(
                color: Color(0xFF1ABC9C),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameController.dispose();
    _studentNoController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    _skillsController.dispose();
    super.dispose();
  }
}