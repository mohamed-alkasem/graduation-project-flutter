// lib/screens/ogrenci/ogrenci_dashboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/gradient_button.dart';
import '../../core/firebase/auth_service.dart';
import '../auth/welcome_screen.dart';
import 'portfolio_screen.dart';
import 'projects_screen.dart';
import 'ogrenci_profile_screen.dart';
class OgrenciDashboard extends StatefulWidget {
  final String email;

  const OgrenciDashboard({super.key, required this.email});

  @override
  _OgrenciDashboardState createState() => _OgrenciDashboardState();
}

class _OgrenciDashboardState extends State<OgrenciDashboard> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? _currentUser;
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

// في دالة _loadUserData في ogrenci_dashboard.dart
  // في دالة _loadUserData في ogrenci_dashboard.dart
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      _currentUser = _authService.getCurrentUser();

      if (_currentUser != null) {
        print('Kullanıcı ID: ${_currentUser!.uid}');
        print('E-posta: ${_currentUser!.email}');

        // Önce öğrenci verilerini al
        _studentData = await _authService.getStudentData(_currentUser!.uid);

        // Eğer veri yoksa, kullanıcı bilgilerini al
        if (_studentData == null) {
          print('Öğrenci verisi bulunamadı, demo veri kullanılıyor...');
          _studentData = {
            'name': widget.email.split('@').first,
            'university': 'Üniversite',
            'department': 'Bölüm',
            'studentNo': '000000',
            'portfolioCount': 0,
            'completedProjects': 0,
            'averageRating': 5.0,
            'views': 0,
            'connections': 0,
          };
        }

        print('Öğrenci verileri yüklendi: $_studentData');
      } else {
        print('Kullanıcı oturumu bulunamadı');
      }
    } catch (e) {
      print('Veri yükleme hatası: $e');
      // Demo veri kullan
      _studentData = {
        'name': widget.email.split('@').first,
        'university': 'Demo Üniversite',
        'department': 'Demo Bölüm',
        'studentNo': '000000',
        'portfolioCount': 0,
        'completedProjects': 0,
        'averageRating': 5.0,
        'views': 0,
        'connections': 0,
      };
    } finally {
      // Kısa bir gecikme ekle (UI için)
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hata'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadUserData(); // Tekrar deneme
              },
              child: const Text('Tekrar Dene'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Dashboard'tan çık
              },
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? _buildLoadingScreen()
          : _buildDashboard(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF1ABC9C)),
          SizedBox(height: 20),
          Text(
            'Profil yükleniyor...',
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: Column(
        children: [
          // AppBar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1ABC9C),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Profil Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF1ABC9C),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),

                // Kullanıcı Bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _studentData?['name'] ?? 'Öğrenci',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _studentData?['university'] ?? 'Üniversite',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      Text(
                        '${_studentData?['department'] ?? 'Bölüm'} - ${_studentData?['studentNo'] ?? 'Öğrenci No'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bildirim ve Çıkış
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _logout,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hoşgeldin Kartı
                  _buildWelcomeCard(),

                  const SizedBox(height: 30),

                  // Yetenek Skoru
                  _buildTalentScoreCard(),

                  const SizedBox(height: 30),

                  // İstatistikler
                  _buildStatisticsSection(),

                  const SizedBox(height: 30),

                  // Hızlı Erişim
                  _buildQuickAccessSection(),

                  const SizedBox(height: 30),

                  // Son Aktivite
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 26, 188, 156),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Color(0xFF1ABC9C),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Başarılarını Paylaş!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      'Projelerini yükle, yeteneklerini sergile',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GradientButton(
            text: 'YENİ PROJE EKLE',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProjectsScreen()),
              );
            },
            gradient: const LinearGradient(
              colors: [Color(0xFF1ABC9C), Color(0xFF16A085)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTalentScoreCard() {
    double score = _studentData?['averageRating'] ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Skor Göstergesi
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    score.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    '/10',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Skor Detayları
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yetenek Karnesi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getTalentLevel(score),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: score / 10,
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  color: const Color(0xFF1ABC9C),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(score * 10).toInt()}% tamamlandı',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 İstatistiklerim',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                title: 'Portföy',
                value: _studentData?['portfolioCount']?.toString() ?? '0',
                icon: Icons.assignment,
                color: const Color(0xFF3498DB),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                title: 'Projeler',
                value: _studentData?['completedProjects']?.toString() ?? '0',
                icon: Icons.code,
                color: const Color(0xFF1ABC9C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                title: 'İnceleme',
                value: _studentData?['views']?.toString() ?? '0',
                icon: Icons.remove_red_eye,
                color: const Color(0xFFE74C3C),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                title: 'Bağlantı',
                value: _studentData?['connections']?.toString() ?? '0',
                icon: Icons.connect_without_contact,
                color: const Color(0xFF9B59B6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🚀 Hızlı Erişim',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildQuickAccessButton(
              title: 'Portföyüm',
              icon: Icons.assignment,
              color: const Color(0xFF3498DB),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PortfolioScreen()),
                );
              },
            ),
            _buildQuickAccessButton(
              title: 'Projelerim',
              icon: Icons.folder,
              color: const Color(0xFF1ABC9C),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProjectsScreen()),
                );
              },
            ),
            _buildQuickAccessButton(
              title: 'Profilim',
              icon: Icons.person,
              color: const Color(0xFFE74C3C),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OgrenciProfileScreen(),
                  ),
                );
              },
            ),
            _buildQuickAccessButton(
              title: 'Şirketler',
              icon: Icons.business,
              color: const Color(0xFF9B59B6),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📝 Son Aktivite',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.add_circle,
                color: const Color(0xFF1ABC9C),
                title: 'Yeni Proje Eklendi',
                subtitle: 'Flutter E-ticaret Uygulaması',
                time: '2 saat önce',
              ),
              const Divider(height: 24),
              _buildActivityItem(
                icon: Icons.thumb_up,
                color: const Color(0xFF3498DB),
                title: 'Projeniz Beğenildi',
                subtitle: 'Akıllı Ev Otomasyonu',
                time: '1 gün önce',
              ),
              const Divider(height: 24),
              _buildActivityItem(
                icon: Icons.remove_red_eye,
                color: const Color(0xFFE74C3C),
                title: 'Profiliniz İncelendi',
                subtitle: 'TechCorp Şirketi',
                time: '2 gün önce',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFFBDC3C7),
          ),
        ),
      ],
    );
  }

  String _getTalentLevel(double score) {
    if (score >= 9) return 'Uzman Seviye';
    if (score >= 7) return 'İleri Seviye';
    if (score >= 5) return 'Orta Seviye';
    if (score >= 3) return 'Başlangıç Seviye';
    return 'Yeni Başladı';
  }

// في دالة _logout في ogrenci_dashboard.dart - تحديث السطر 728
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.logout();
              // تصحيح: استخدام MaterialPageRoute بدلاً من pushNamedAndRemoveUntil
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (route) => false,
              );
            },
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}