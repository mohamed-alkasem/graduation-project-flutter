// lib/screens/auth/sirket/sirket_register.dart
import 'package:flutter/material.dart';
import 'package:bitirmetezimobil/widgets/custom_text_field.dart';
import 'package:bitirmetezimobil/widgets/gradient_button.dart';
import '../../../screens/auth/sirket/sirket_login.dart';

class SirketRegister extends StatefulWidget {
  const SirketRegister({super.key});

  @override
  _SirketRegisterState createState() => _SirketRegisterState();
}

class _SirketRegisterState extends State<SirketRegister> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _sectorController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _taxNoController = TextEditingController();

  // Sectors List
  final List<String> _sectors = [
    'Teknoloji',
    'Finans',
    'Sağlık',
    'Eğitim',
    'Üretim',
    'Perakende',
    'Turizm',
    'Enerji',
    'İnşaat',
    'Diğer'
  ];
  String _selectedSector = 'Teknoloji';

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
                      'Şirket Kayıt',
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
                'Üniversite öğrencilerinin yeteneklerini keşfetmek için kaydolun',
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
                        // Şirket Bilgileri
                        const Text(
                          '🏢 Şirket Bilgileri',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          controller: _companyNameController,
                          label: 'Şirket Adı',
                          prefixIcon: Icons.business,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen şirket adını girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _contactPersonController,
                          label: 'Yetkili Kişi Adı',
                          prefixIcon: Icons.person,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen yetkili kişi adını girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _taxNoController,
                                label: 'Vergi No',
                                prefixIcon: Icons.numbers,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                      return 'Geçerli bir vergi numarası girin (10 hane)';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _phoneController,
                                label: 'Telefon',
                                prefixIcon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                isRequired: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lütfen telefon numaranızı girin';
                                  }
                                  if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                                    return 'Geçerli bir telefon numarası girin';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Sektör Seçimi
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sektör',
                              style: TextStyle(
                                color: Color(0xFF2C3E50),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE0E0E0)),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedSector,
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
                                items: _sectors.map((String sector) {
                                  return DropdownMenuItem<String>(
                                    value: sector,
                                    child: Text(sector),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedSector = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _websiteController,
                          label: 'Website (Opsiyonel)',
                          prefixIcon: Icons.language,
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _addressController,
                          label: 'Adres',
                          prefixIcon: Icons.location_on,
                          maxLines: 2,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen şirket adresini girin';
                            }
                            return null;
                          },
                        ),

                        // İletişim Bilgileri
                        const SizedBox(height: 30),
                        const Text(
                          '📧 İletişim Bilgileri',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 20),

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
                            if (value.length < 8) {
                              return 'Şifre en az 8 karakter olmalıdır';
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

                        // Şartlar ve Koşullar
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Checkbox(
                              value: true,
                              onChanged: (value) {},
                              activeColor: const Color(0xFFE74C3C),
                            ),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(color: Colors.black87, fontSize: 14),
                                  children: [
                                    TextSpan(text: 'Kabul ediyorum: '),
                                    TextSpan(
                                      text: 'Kullanım Şartları',
                                      style: TextStyle(
                                        color: Color(0xFFE74C3C),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: ' ve '),
                                    TextSpan(
                                      text: 'Gizlilik Politikası',
                                      style: TextStyle(
                                        color: Color(0xFFE74C3C),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Kayıt Butonu
                        GradientButton(
                          text: 'ŞİRKET HESABI OLUŞTUR',
                          onPressed: _registerCompany,
                          isLoading: _isLoading,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Zaten Hesabı Var
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Zaten şirket hesabınız var mı? '),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SirketLogin(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  color: Color(0xFFE74C3C),
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

  Future<void> _registerCompany() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // TODO: Firebase kayıt işlemleri burada yapılacak
      // AuthService().registerCompany(...)

      await Future.delayed(const Duration(seconds: 2)); // Simülasyon

      setState(() => _isLoading = false);

      // Başarılı kayıt sonrası
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Şirket Kaydı Başarılı!'),
        content: const Text(
          'Şirket hesabınız başarıyla oluşturuldu. '
              'Hesabınız yönetici onayından sonra aktif olacaktır. '
              'Onay süreci genellikle 24 saat içinde tamamlanır.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog'u kapat
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SirketLogin(),
                ),
              );
            },
            child: const Text('TAMAM'),
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
    _companyNameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _sectorController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _taxNoController.dispose();
    super.dispose();
  }
}