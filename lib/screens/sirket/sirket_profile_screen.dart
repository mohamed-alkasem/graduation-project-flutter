import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/firebase/auth_service.dart';
import '../../core/models/user_model.dart';

class SirketProfileScreen extends StatefulWidget {
  const SirketProfileScreen({super.key});

  @override
  State<SirketProfileScreen> createState() => _SirketProfileScreenState();
}

class _SirketProfileScreenState extends State<SirketProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _sectorController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  User? _currentUser;
  UserModel? _companyData;

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
        _showSnackBar('Oturum bilgisi bulunamadı', isError: true);
        Navigator.pop(context);
        return;
      }

      _companyData = await _authService.getUserData(_currentUser!.uid);

      if (_companyData != null) {
        _companyNameController.text = _companyData!.companyName ?? '';
        _contactPersonController.text = _companyData!.name;
        _sectorController.text = _companyData!.sector ?? '';
        _phoneController.text = _companyData!.companyPhone ?? '';
        _addressController.text = _companyData!.address ?? '';
        _websiteController.text = _companyData!.website ?? '';
        _descriptionController.text = _companyData!.companyDescription ?? '';
      } else {
        _contactPersonController.text = _currentUser!.displayName ?? '';
      }
    } catch (e) {
      _showSnackBar('Profil bilgileri alınamadı: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _currentUser == null) return;

    setState(() => _isSaving = true);

    try {
      await _authService.updateCompanyProfile(
        userId: _currentUser!.uid,
        companyName: _companyNameController.text,
        contactPerson: _contactPersonController.text,
        sector: _sectorController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        website: _websiteController.text,
        companyDescription: _descriptionController.text,
      );

      _showSnackBar('Şirket profili güncellendi');
      await _loadProfile();
    } catch (e) {
      _showSnackBar('Profil kaydedilemedi: $e', isError: true);
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
        backgroundColor: isError ? Colors.redAccent : const Color(0xFFE74C3C),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şirket Profili'),
        backgroundColor: const Color(0xFFE74C3C),
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
                      _buildOverviewCard(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Şirket Bilgileri'),
                      _buildTextField(
                        controller: _companyNameController,
                        label: 'Şirket Adı',
                        icon: Icons.business,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Şirket adı gerekli' : null,
                      ),
                      _buildTextField(
                        controller: _sectorController,
                        label: 'Sektör',
                        icon: Icons.work,
                        validator: (value) => value == null || value.isEmpty ? 'Sektör gerekli' : null,
                      ),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Adres',
                        icon: Icons.location_on,
                        maxLines: 2,
                        validator: (value) => value == null || value.isEmpty ? 'Adres gerekli' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildSectionTitle('İletişim ve Tanıtım'),
                      _buildTextField(
                        controller: _contactPersonController,
                        label: 'İletişim Sorumlusu',
                        icon: Icons.person,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'İletişim kişisi gerekli' : null,
                      ),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Telefon',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty ? 'Telefon gerekli' : null,
                      ),
                      _buildTextField(
                        controller: _websiteController,
                        label: 'Web Sitesi',
                        icon: Icons.public,
                        keyboardType: TextInputType.url,
                      ),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Şirket Tanımı',
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
              backgroundColor: const Color(0xFFE74C3C),
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
            label: Text(_isSaving ? 'Kaydediliyor...' : 'Profili Kaydet'),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.apartment, color: Color(0xFFE74C3C), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _companyData?.companyName ?? 'Şirket',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _companyData?.email ?? _currentUser?.email ?? '',
                  style: const TextStyle(color: Colors.white70),
                )
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

  Widget _buildOverviewCard() {
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
            'Profil Özeti',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildChip(Icons.work, _companyData?.sector ?? 'Sektör'),
              const SizedBox(width: 8),
              _buildChip(Icons.location_on, _companyData?.address ?? 'Adres'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildChip(Icons.person, _companyData?.name ?? 'İletişim Sorumlusu'),
              const SizedBox(width: 8),
              _buildChip(Icons.phone, _companyData?.companyPhone ?? 'Telefon'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE74C3C), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFE74C3C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
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
}
