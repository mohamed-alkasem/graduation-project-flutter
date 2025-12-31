import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/firebase/auth_service.dart';
import '../../core/models/user_model.dart';

class OgrenciProfileScreen extends StatefulWidget {
  const OgrenciProfileScreen({super.key});

  @override
  State<OgrenciProfileScreen> createState() => _OgrenciProfileScreenState();
}

class _OgrenciProfileScreenState extends State<OgrenciProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _studentNoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  UserModel? _userData;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      _currentUser = _authService.getCurrentUser();
      if (_currentUser == null) {
        _showSnackBar('Kullanıcı oturumu bulunamadı', isError: true);
        Navigator.pop(context);
        return;
      }

      _userData = await _authService.getUserData(_currentUser!.uid);

      if (_userData != null) {
        _nameController.text = _userData!.name;
        _universityController.text = _userData!.university ?? '';
        _departmentController.text = _userData!.department ?? '';
        _studentNoController.text = _userData!.studentNo ?? '';
        _phoneController.text = _userData!.phone ?? '';
        _skillsController.text = _userData!.skills?.join(', ') ?? '';
        _bioController.text = _userData!.bio ?? '';
      } else {
        _nameController.text = _currentUser!.displayName ?? '';
        _studentNoController.text = '';
      }
    } catch (e) {
      _showSnackBar('Profil yüklenirken hata oluştu: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _currentUser == null) return;

    setState(() => _isSaving = true);

    final skills = _skillsController.text
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();

    try {
      await _authService.updateStudentProfile(
        userId: _currentUser!.uid,
        name: _nameController.text,
        university: _universityController.text,
        department: _departmentController.text,
        studentNo: _studentNoController.text,
        phone: _phoneController.text,
        skills: skills,
        bio: _bioController.text,
      );

      _showSnackBar('Profil başarıyla güncellendi');
      await _loadProfile();
    } catch (e) {
      _showSnackBar('Profil güncellenemedi: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF1ABC9C),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: const Color(0xFF1ABC9C),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1ABC9C)))
          : SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildInfoCard(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Kişisel Bilgiler'),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Ad Soyad',
                        icon: Icons.person,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Ad soyad gerekli' : null,
                      ),
                      _buildTextField(
                        controller: _studentNoController,
                        label: 'Öğrenci Numarası',
                        icon: Icons.badge,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Öğrenci numarası gerekli' : null,
                      ),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Telefon',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Eğitim Bilgileri'),
                      _buildTextField(
                        controller: _universityController,
                        label: 'Üniversite',
                        icon: Icons.school,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Üniversite gerekli' : null,
                      ),
                      _buildTextField(
                        controller: _departmentController,
                        label: 'Bölüm',
                        icon: Icons.menu_book,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Bölüm gerekli' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Yetenekler ve Hakkımda'),
                      _buildTextField(
                        controller: _skillsController,
                        label: 'Yetenekler (virgülle ayırınız)',
                        icon: Icons.star,
                        helperText: 'Örnek: Flutter, Firebase, UI/UX',
                      ),
                      _buildTextField(
                        controller: _bioController,
                        label: 'Hakkımda',
                        icon: Icons.description,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1ABC9C),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Kaydediliyor...' : 'Profili Güncelle'),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1ABC9C), Color(0xFF16A085)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Color(0xFF1ABC9C), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData?.name ?? 'Öğrenci',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _userData?.email ?? _currentUser?.email ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil Özetin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildChip(Icons.school, _userData?.university ?? 'Üniversite'),
              const SizedBox(width: 8),
              _buildChip(Icons.menu_book, _userData?.department ?? 'Bölüm'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildChip(Icons.badge, _userData?.studentNo ?? 'Öğrenci No'),
              if ((_userData?.skills ?? []).isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildChip(Icons.star, '${_userData!.skills!.length} yetenek'),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1ABC9C).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF1ABC9C), size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1ABC9C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          prefixIcon: Icon(icon, color: const Color(0xFF1ABC9C)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
      ),
    );
  }
}
