import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/firebase/auth_service.dart';
import '../../core/firebase/storage_service.dart';

class SirketProfileScreen extends StatefulWidget {
  const SirketProfileScreen({super.key});

  @override
  State<SirketProfileScreen> createState() => _SirketProfileScreenState();
}

class _SirketProfileScreenState extends State<SirketProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  Map<String, dynamic>? _companyData;

  bool _isLoading = true;
  bool _isSaving = false;

  File? _selectedLogo;
  String? _logoUrl;

  // controllers
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _sectorController = TextEditingController(); // fallback
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // dropdowns
  final List<String> _sectors = const [
    'Teknoloji',
    'Finans',
    'Sağlık',
    'Eğitim',
    'Üretim',
    'Perakende',
    'Turizm',
    'Enerji',
    'İnşaat',
    'Diğer',
  ];
  String? _selectedSector;

  final List<String> _companySizes = const [
    'Küçük (1-50 çalışan)',
    'Orta (51-250 çalışan)',
    'Büyük (250+ çalışan)',
  ];
  String? _selectedCompanySize;

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
        _showSnack('Oturum bilgisi bulunamadı', isError: true);
        if (mounted) Navigator.pop(context);
        return;
      }

      final doc = await _authService.getUserDoc(_currentUser!.uid);
      if (!doc.exists) {
        // fallback minimum
        _companyData = {
          'email': _currentUser!.email,
          'name': _currentUser!.displayName ?? '',
          'companyName': '',
          'sector': '',
          'address': '',
          'companyPhone': '',
          'website': '',
          'companyDescription': '',
          'companyLogoUrl': '',
          'companySize': '',
          'status': 'active',
        };
      } else {
        _companyData = doc.data();
      }

      // Also get from profiles collection for companySize
      try {
        final profileDoc = await _firestore
            .collection('profiles')
            .doc(_currentUser!.uid)
            .get();
        if (profileDoc.exists && profileDoc.data() != null) {
          final profileData = profileDoc.data()!;
          // Merge profile data, especially companySize
          _companyData = {
            ..._companyData ?? {},
            ...profileData,
          };
        }
      } catch (e) {
        print('Profiles collection okuma hatası: $e');
      }

      _fillControllersFromUsersDoc();
    } catch (e) {
      _showSnack('Profil yüklenemedi: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _fillControllersFromUsersDoc() {
    final d = _companyData ?? {};

    _companyNameController.text = (d['companyName'] ?? '').toString();
    _contactPersonController.text =
        (d['contactPerson'] ?? d['name'] ?? '').toString();

    _selectedSector = (d['sector'] ?? '').toString().isEmpty
        ? null
        : (d['sector'] ?? '').toString();

    _sectorController.text = (d['sector'] ?? '').toString(); // fallback

    _phoneController.text = (d['companyPhone'] ?? '').toString();
    _addressController.text = (d['address'] ?? '').toString();
    _websiteController.text = (d['website'] ?? '').toString();
    _descriptionController.text = (d['companyDescription'] ?? '').toString();

    _selectedCompanySize = (d['companySize'] ?? '').toString().isEmpty
        ? null
        : (d['companySize'] ?? '').toString();

    _logoUrl = (d['companyLogoUrl'] ?? '').toString();
  }

  Future<void> _pickLogo() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _selectedLogo = File(picked.path);
    });

    await _uploadLogo();
  }

  Future<void> _uploadLogo() async {
    if (_selectedLogo == null || _currentUser == null) return;

    try {
      setState(() => _isSaving = true);

      final url = await _storageService.uploadProfileImage(
        _selectedLogo!,
        _currentUser!.uid,
        false, // isStudent = false
      );

      await _authService.updateCompanyLogo(
        userId: _currentUser!.uid,
        logoUrl: url,
      );

      setState(() {
        _logoUrl = url;
        _selectedLogo = null;
      });

      await _loadProfile(); // ✅ لتحديث الهيدر/الكروت فوراً
      _showSnack('Şirket logosu güncellendi');
    } catch (e) {
      _showSnack('Logo yüklenemedi: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_currentUser == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final sector = _selectedSector ?? _sectorController.text;

      await _authService.updateCompanyProfile(
        userId: _currentUser!.uid,
        companyName: _companyNameController.text,
        contactPerson: _contactPersonController.text,
        sector: sector,
        address: _addressController.text,
        phone: _phoneController.text,
        website: _websiteController.text,
        companyDescription: _descriptionController.text,
      );

      if (_selectedCompanySize != null && _selectedCompanySize!.trim().isNotEmpty) {
        await _authService.updateCompanySize(
          userId: _currentUser!.uid,
          companySize: _selectedCompanySize!,
        );
      }

      _showSnack('Şirket profili güncellendi');
      await _loadProfile(); // ✅ ترجع تقرأ من users وتنعكس فوراً
    } catch (e) {
      _showSnack('Profil kaydedilemedi: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFFE74C3C),
      ),
    );
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
          _showSnack('Çıkış yapılamadı: $e', isError: true);
        }
      }
    }
  }

  // ===== UI Helpers =====

  Widget _buildLogo() {
    return GestureDetector(
      onTap: _isSaving ? null : _pickLogo,
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE74C3C), width: 3),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _logoUrl != null && _logoUrl!.isNotEmpty
                  ? Image.network(
                _logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.apartment,
                  size: 60,
                  color: Color(0xFFE74C3C),
                ),
              )
                  : _selectedLogo != null
                  ? Image.file(_selectedLogo!, fit: BoxFit.cover)
                  : const Icon(
                Icons.apartment,
                size: 60,
                color: Color(0xFFE74C3C),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFE74C3C),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final status = (_companyData?['status'] ?? 'active').toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE74C3C), Color(0xFFC0392B)]),
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
          _buildLogo(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _companyNameController.text.isNotEmpty
                      ? _companyNameController.text
                      : (_companyData?['companyName'] ?? 'Şirket').toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _currentUser?.email ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                _buildStatusChip(status),
              ],
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : _loadProfile,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color c;
    String t;

    switch (status) {
      case 'approved':
      case 'active':
        c = Colors.green;
        t = 'Aktif';
        break;
      case 'rejected':
        c = Colors.red;
        t = 'Reddedildi';
        break;
      case 'pending_approval':
        c = Colors.orange;
        t = 'Onay Bekliyor';
        break;
      default:
        c = Colors.orange;
        t = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.6)),
      ),
      child: Text(
        'Durum: $t',
        style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

  Widget _buildSectionTitle(String t) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(
      t,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
    ),
  );

  Widget _field({
    required TextEditingController c,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFE74C3C)),
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

  Widget _dropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 14)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
            hint: Row(
              children: [
                Icon(icon, color: const Color(0xFFE74C3C), size: 18),
                const SizedBox(width: 8),
                const Text('Seçiniz'),
              ],
            ),
            items: items
                .map((e) => DropdownMenuItem<String>(
              value: e,
              child: Text(e),
            ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Şirket Profili'),
        backgroundColor: const Color(0xFFE74C3C),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadProfile,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE74C3C)))
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

                _buildSectionTitle('Şirket Bilgileri'),
                _field(
                  c: _companyNameController,
                  label: 'Şirket Adı',
                  icon: Icons.business,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Şirket adı gerekli' : null,
                ),
                _field(
                  c: _contactPersonController,
                  label: 'İletişim Sorumlusu',
                  icon: Icons.person,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'İletişim kişisi gerekli' : null,
                ),

                _dropdown(
                  label: 'Sektör',
                  icon: Icons.work,
                  items: _sectors,
                  value: _selectedSector,
                  onChanged: (v) => setState(() => _selectedSector = v),
                ),
                const SizedBox(height: 14),

                _dropdown(
                  label: 'Şirket Büyüklüğü',
                  icon: Icons.groups,
                  items: _companySizes,
                  value: _selectedCompanySize,
                  onChanged: (v) => setState(() => _selectedCompanySize = v),
                ),
                const SizedBox(height: 14),

                _field(
                  c: _phoneController,
                  label: 'Telefon',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Telefon gerekli' : null,
                ),
                _field(
                  c: _addressController,
                  label: 'Adres',
                  icon: Icons.location_on,
                  maxLines: 2,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Adres gerekli' : null,
                ),
                _field(
                  c: _websiteController,
                  label: 'Web Sitesi',
                  icon: Icons.public,
                  keyboardType: TextInputType.url,
                ),
                _field(
                  c: _descriptionController,
                  label: 'Şirket Tanımı',
                  icon: Icons.description,
                  maxLines: 4,
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
              backgroundColor: const Color(0xFFE74C3C),
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
            label: Text(_isSaving ? 'Kaydediliyor...' : 'Profili Kaydet'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _contactPersonController.dispose();
    _sectorController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
