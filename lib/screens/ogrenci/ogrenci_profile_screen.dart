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
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();

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
        if (mounted) Navigator.pop(context);
        return;
      }

      final data = await _authService.getUserData(_currentUser!.uid);

      // ✅ لو ما في document بالـ users لسبب ما، اعمل fallback
      if (data == null) {
        setState(() {
          _userData = UserModel(
            id: _currentUser!.uid,
            email: _currentUser!.email ?? '',
            name: _currentUser!.displayName ?? '',
            role: 'ogrenci',
            createdAt: DateTime.now(),
            status: 'active',
          );
        });

        _nameController.text = _userData!.name;
        _universityController.text = '';
        _departmentController.text = '';
        _studentNoController.text = '';
        _phoneController.text = '';
        _skillsController.text = '';
        _bioController.text = '';
        _gradeController.text = '';
        _hobbiesController.text = '';
      } else {
        setState(() => _userData = data);

        _nameController.text = data.name;
        _universityController.text = data.university ?? '';
        _departmentController.text = data.department ?? '';
        _studentNoController.text = data.studentNo ?? '';
        _phoneController.text = data.phone ?? '';
        _skillsController.text = (data.skills ?? []).join(', ');
        _bioController.text = data.bio ?? '';
        _gradeController.text = data.grade ?? '';
        _hobbiesController.text = (data.hobbies ?? []).join(', ');
      }
    } catch (e) {
      _showSnackBar('Profil yüklenirken hata oluştu: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

    final hobbies = _hobbiesController.text
        .split(',')
        .map((hobby) => hobby.trim())
        .where((hobby) => hobby.isNotEmpty)
        .toList();

    try {
      await _authService.updateStudentProfile(
        userId: _currentUser!.uid,
        name: _nameController.text.trim(),
        university: _universityController.text.trim(),
        department: _departmentController.text.trim(),
        studentNo: _studentNoController.text.trim(),
        phone: _phoneController.text.trim(),
        skills: skills,
        bio: _bioController.text.trim(),
        grade: _gradeController.text.trim().isEmpty ? null : _gradeController.text.trim(),
        hobbies: hobbies.isEmpty ? null : hobbies,
      );

      // ✅ تحديث فوري للواجهة (بدون انتظار التحميل)
      setState(() {
        _userData = (_userData ?? UserModel(
          id: _currentUser!.uid,
          email: _currentUser!.email ?? '',
          name: '',
          role: 'ogrenci',
          createdAt: DateTime.now(),
          status: 'active',
        )).copyWith(
          name: _nameController.text.trim(),
          university: _universityController.text.trim(),
          department: _departmentController.text.trim(),
          studentNo: _studentNoController.text.trim(),
          phone: _phoneController.text.trim(),
          skills: skills,
          bio: _bioController.text.trim(),
          grade: _gradeController.text.trim().isEmpty ? null : _gradeController.text.trim(),
          hobbies: hobbies.isEmpty ? null : hobbies,
          status: 'active',
        );
      });

      _showSnackBar('Profil başarıyla güncellendi');

      // ✅ وبعدها تحميل من Firestore للتأكد (اختياري لكنه ممتاز)
      await _loadProfile();
    } catch (e) {
      _showSnackBar('Profil güncellenemedi: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _authService.logout();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar('Çıkış yapılamadı: $e', isError: true);
        }
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
        actions: [
          IconButton(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
          ),
        ],
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
                  value == null || value.trim().isEmpty ? 'Ad soyad gerekli' : null,
                ),
                _buildTextField(
                  controller: _studentNoController,
                  label: 'Öğrenci Numarası',
                  icon: Icons.badge,
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Öğrenci numarası gerekli' : null,
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
                  value == null || value.trim().isEmpty ? 'Üniversite gerekli' : null,
                ),
                _buildTextField(
                  controller: _departmentController,
                  label: 'Bölüm',
                  icon: Icons.menu_book,
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Bölüm gerekli' : null,
                ),
                _buildTextField(
                  controller: _gradeController,
                  label: 'Sınıf/Sınıf Seviyesi',
                  icon: Icons.class_,
                  helperText: 'Örnek: 3. Sınıf, Lisans 2, vb.',
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
                _buildTextField(
                  controller: _hobbiesController,
                  label: 'Hobiler (virgülle ayırınız)',
                  icon: Icons.sports_esports,
                  helperText: 'Örnek: Futbol, Müzik, Kitap Okuma',
                ),

                const SizedBox(height: 90),
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
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Color(0xFF1ABC9C), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData?.name.isNotEmpty == true ? _userData!.name : 'Öğrenci',
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
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final skillsCount = (_userData?.skills ?? []).length;

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(Icons.school, _userData?.university ?? 'Üniversite'),
              _buildChip(Icons.menu_book, _userData?.department ?? 'Bölüm'),
              _buildChip(Icons.badge, _userData?.studentNo ?? 'Öğrenci No'),
              if (skillsCount > 0) _buildChip(Icons.star, '$skillsCount yetenek'),
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

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    _studentNoController.dispose();
    _phoneController.dispose();
    _skillsController.dispose();
    _bioController.dispose();
    _gradeController.dispose();
    _hobbiesController.dispose();
    super.dispose();
  }
}
