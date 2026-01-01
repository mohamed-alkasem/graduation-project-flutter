// lib/screens/sirket/sirket_dashboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/firebase/auth_service.dart';
import '../../core/models/user_model.dart';
import '../../core/models/profile_model.dart';
import '../../core/services/profile_service.dart';
import '../../widgets/gradient_button.dart';
import 'sirket_profile_screen.dart';
import 'student_search_screen.dart';
import 'quizzes_list_screen.dart';
import 'internship_requests_list_screen.dart';

class SirketDashboard extends StatefulWidget {
  const SirketDashboard({super.key});

  @override
  State<SirketDashboard> createState() => _SirketDashboardState();
}

class _SirketDashboardState extends State<SirketDashboard> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  User? _currentUser;
  UserModel? _userData; // users
  ProfileModel? _profileData; // profiles

  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    setState(() => _isLoading = true);

    try {
      _currentUser = _authService.getCurrentUser();
      if (_currentUser == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      _userData = await _authService.getUserData(_currentUser!.uid);
      _profileData = await _profileService.getProfileByUserId(_currentUser!.uid);

      _userData ??= UserModel(
        id: _currentUser!.uid,
        email: _currentUser!.email ?? '',
        name: _currentUser!.displayName ?? 'Yetkili',
        role: 'sirket',
        createdAt: DateTime.now(),
        companyName: 'Şirket',
        sector: 'Sektör',
        companyPhone: '',
        address: '',
        status: 'pending',
      );
    } catch (e) {
      debugPrint('Şirket veri yükleme hatası: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async => _loadCompanyData();

  // ===== unified getters =====
  String get _companyName {
    final a = _userData?.companyName;
    final b = _profileData?.companyName;
    if (a != null && a.trim().isNotEmpty) return a.trim();
    if (b != null && b.trim().isNotEmpty) return b.trim();
    return 'Şirket';
  }

  String get _sector {
    final a = _userData?.sector;
    final b = _profileData?.sector;
    if (a != null && a.trim().isNotEmpty) return a.trim();
    if (b != null && b.trim().isNotEmpty) return b.trim();
    return 'Sektör';
  }

  String get _contactPerson {
    final a = _userData?.name; // users.name
    final b = _profileData?.contactPerson; // profiles.contactPerson
    if (a != null && a.trim().isNotEmpty) return a.trim();
    if (b != null && b.trim().isNotEmpty) return b.trim();
    return 'Yetkili';
  }

  String get _status {
    final a = _profileData?.status;
    final b = _userData?.status;
    if (a != null && a.trim().isNotEmpty) return a.trim();
    if (b != null && b.trim().isNotEmpty) return b.trim();
    return 'pending';
  }

  String? get _logoUrl {
    final url = _profileData?.companyLogoUrl;
    if (url == null) return null;
    if (url.trim().isEmpty) return null;
    return url.trim();
  }

  void _onItemTapped(int i) => setState(() => _selectedIndex = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading ? _buildLoadingScreen() : _buildDashboard(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFE74C3C)),
          SizedBox(height: 20),
          Text('Yükleniyor...', style: TextStyle(color: Color(0xFF2C3E50), fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomeTab(),
                _buildSearchTab(),
                const QuizzesListScreen(),
                const InternshipRequestsListScreen(),
                const SirketProfileScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFE74C3C),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _logoUrl != null
                  ? Image.network(
                _logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.business, color: Color(0xFFE74C3C), size: 30),
              )
                  : const Icon(Icons.business, color: Color(0xFFE74C3C), size: 30),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _companyName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(_sector, style: const TextStyle(fontSize: 14, color: Colors.white)),
                Text(_contactPerson, style: const TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _refreshData),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFFE74C3C),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 30),
            _buildStatusCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, spreadRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoş Geldiniz!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          ),
          const SizedBox(height: 8),
          Text(_companyName, style: const TextStyle(color: Color(0xFF7F8C8D))),
          const SizedBox(height: 20),
          GradientButton(
            text: 'ÖĞRENCİ ARA',
            onPressed: () => setState(() => _selectedIndex = 1),
            gradient: const LinearGradient(colors: [Color(0xFFE74C3C), Color(0xFFC0392B)]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _status;

    Color statusColor;
    String statusText;
    String statusDescription;

    switch (status) {
      case 'approved':
      case 'active':
        statusColor = const Color(0xFF2ECC71);
        statusText = 'Onaylandı';
        statusDescription = 'Hesabınız aktif olarak kullanılabilir.';
        break;
      case 'rejected':
        statusColor = const Color(0xFFE74C3C);
        statusText = 'Reddedildi';
        statusDescription = _profileData?.rejectionReason ?? 'Yönetici tarafından reddedildi.';
        break;
      case 'pending_approval':
        statusColor = const Color(0xFFF39C12);
        statusText = 'Yönetici Onayı Bekliyor';
        statusDescription = 'Hesabınız yönetici tarafından inceleniyor.';
        break;
      default:
        statusColor = const Color(0xFFF39C12);
        statusText = 'Onay Bekliyor';
        statusDescription = 'Hesabınız yönetici onayı bekliyor.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, spreadRadius: 2)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(_getStatusIcon(status), color: statusColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(statusText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor)),
                const SizedBox(height: 6),
                Text(statusDescription, style: const TextStyle(color: Color(0xFF7F8C8D))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
      case 'active':
        return Icons.verified;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  Widget _buildSearchTab() => const StudentSearchScreen();

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Arama'),
        BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quizler'),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Stajlar'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFFE74C3C),
      unselectedItemColor: const Color(0xFF95A5A6),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
    );
  }
}
