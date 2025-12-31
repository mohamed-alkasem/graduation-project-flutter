// lib/screens/auth/sirket/sirket_login.dart
import 'package:flutter/material.dart';
import 'package:bitirmetezimobil/widgets/custom_text_field.dart';
import 'package:bitirmetezimobil/widgets/gradient_button.dart';
import 'sirket_register.dart';
import '../../../screens/sirket/sirket_dashboard.dart';

class SirketLogin extends StatefulWidget {
  const SirketLogin({super.key});

  @override
  _SirketLoginState createState() => _SirketLoginState();
}

class _SirketLoginState extends State<SirketLogin> {
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
                      'Şirket Giriş',
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
                'Öğrenci yeteneklerini keşfetmek için giriş yapın',
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
                            color: const Color(0xFFE74C3C).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.business,
                            size: 40,
                            color: Color(0xFFE74C3C),
                          ),
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          controller: _emailController,
                          label: 'Şirket E-posta Adresi',
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
                              style: TextStyle(color: Color(0xFFE74C3C)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Giriş Butonu
                        GradientButton(
                          text: 'ŞİRKET GİRİŞİ YAP',
                          onPressed: _loginCompany,
                          isLoading: _isLoading,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Hesap Oluştur
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Şirket hesabınız yok mu? '),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SirketRegister(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Kayıt Ol',
                                style: TextStyle(
                                  color: Color(0xFFE74C3C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Ek Bilgi
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.info_outline, color: Color(0xFFE74C3C)),
                              SizedBox(height: 8),
                              Text(
                                'Not: Şirket hesapları yönetici onayı gerektirir. '
                                    'Onay süreci genellikle 24 saat içinde tamamlanır.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7F8C8D),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
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

  Future<void> _loginCompany() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // TODO: Firebase giriş işlemleri burada yapılacak
      // AuthService().loginCompany(...)

      await Future.delayed(const Duration(seconds: 1)); // Simülasyon

      setState(() => _isLoading = false);

      // Başarılı giriş sonrası dashboard'a yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SirketDashboard(email: _emailController.text),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}