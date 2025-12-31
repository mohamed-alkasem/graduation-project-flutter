// lib/screens/auth/ogrenci/ogrenci_login.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bitirmetezimobil/widgets/custom_text_field.dart';
import 'package:bitirmetezimobil/widgets/gradient_button.dart';
import 'ogrenci_register.dart';
import '../../../screens/ogrenci/ogrenci_dashboard.dart';

class OgrenciLogin extends StatefulWidget {
  const OgrenciLogin({super.key});

  @override
  _OgrenciLoginState createState() => _OgrenciLoginState();
}

class _OgrenciLoginState extends State<OgrenciLogin> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                      'Öğrenci Giriş',
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
                'Portföyünüze erişmek için giriş yapın',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 30),

              // Login Form
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
                        // Logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1ABC9C).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.school,
                            size: 40,
                            color: Color(0xFF1ABC9C),
                          ),
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          controller: _emailController,
                          label: 'E-posta Adresi',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen e-posta adresinizi girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _passwordController,
                          label: 'Şifre',
                          prefixIcon: Icons.lock,
                          obscureText: _obscurePassword,
                          isPassword: true,
                          onToggleVisibility: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen şifrenizi girin';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Şifremi Unuttum
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Şifremi unuttum sayfası
                            },
                            child: const Text(
                              'Şifremi unuttum',
                              style: TextStyle(color: Color(0xFF1ABC9C)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Giriş Butonu
                        GradientButton(
                          text: 'GİRİŞ YAP',
                          onPressed: _loginStudent,
                          isLoading: _isLoading,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1ABC9C), Color(0xFF16A085)],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Hesap Oluştur
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Hesabınız yok mu? '),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OgrenciRegister(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Kayıt Ol',
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

  Future<void> _loginStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        print('🎯 Öğrenci girişi başlıyor...');

        // فقط Firebase Authentication ile giriş
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final User user = userCredential.user!;
        print('✅ Firebase Auth başarılı, User ID: ${user.uid}');
        print('✅ Email: ${user.email}');

        // مباشرة الانتقال للـ Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OgrenciDashboard(email: user.email ?? ''),
          ),
        );

      } on FirebaseAuthException catch (e) {
        print('❌ Firebase Auth Hatası: ${e.code} - ${e.message}');

        String errorMessage = 'Giriş başarısız: ';
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
            break;
          case 'wrong-password':
            errorMessage = 'Hatalı şifre.';
            break;
          case 'invalid-email':
            errorMessage = 'Geçersiz e-posta formatı.';
            break;
          case 'user-disabled':
            errorMessage = 'Bu hesap devre dışı bırakıldı.';
            break;
          case 'too-many-requests':
            errorMessage = 'Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin.';
            break;
          default:
            errorMessage = 'Giriş başarısız: ${e.message ?? 'Bilinmeyen hata'}';
        }

        _showErrorDialog(errorMessage);
      } catch (e) {
        print('❌ Genel Hata: $e');
        _showErrorDialog('Giriş sırasında hata oluştu: ${e.toString()}');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Giriş Hatası'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}