// lib/screens/ogrenci/ogrenci_dashboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../core/firebase/auth_service.dart';
import '../../core/models/user_model.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/theme_provider.dart';
import '../../widgets/gradient_button.dart';

import 'portfolio_screen.dart';
import 'projects_screen.dart';
import 'ogrenci_profile_screen.dart'; // ✅ الصفحة الجديدة اللي تعتمد users
import 'quizzes_screen.dart';
import 'internship_requests_screen.dart';
import 'notifications_screen.dart';

class OgrenciDashboard extends StatefulWidget {
  const OgrenciDashboard({super.key});

  @override
  State<OgrenciDashboard> createState() => _OgrenciDashboardState();
}


class _OgrenciDashboardState extends State<OgrenciDashboard> {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  User? _currentUser;
  UserModel? _student;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      _currentUser = _authService.getCurrentUser();
      if (_currentUser == null) {
        // ما في جلسة
        setState(() => _student = null);
        return;
      }

      final data = await _authService.getUserData(_currentUser!.uid);

      if (data != null) {
        setState(() => _student = data);
      } else {
        // fallback: لو ما لقى doc بالـ users
        setState(() {
          final fallbackEmail = _currentUser?.email ?? '';
          final fallbackName = (_currentUser?.displayName?.trim().isNotEmpty == true)
              ? _currentUser!.displayName!.trim()
              : (fallbackEmail.isNotEmpty ? fallbackEmail.split('@').first : 'Öğrenci');

          _student = UserModel(
            id: _currentUser!.uid,
            email: fallbackEmail,
            name: fallbackName,
            role: 'ogrenci',
            createdAt: DateTime.now(),
            university: 'Üniversiteniz',
            department: 'Bölümünüz',
            studentNo: '000000',
            skills: const [],
            status: 'active',
          );

        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Veri yükleme hatası: $e');

      // Demo fallback
      setState(() {
        final fallbackEmail = _currentUser?.email ?? '';
        final fallbackName = (_currentUser?.displayName?.trim().isNotEmpty == true)
            ? _currentUser!.displayName!.trim()
            : (fallbackEmail.isNotEmpty ? fallbackEmail.split('@').first : 'Öğrenci');

        _student = UserModel(
          id: _currentUser!.uid,
          email: fallbackEmail,
          name: fallbackName,
          role: 'ogrenci',
          createdAt: DateTime.now(),
          university: 'Üniversiteniz',
          department: 'Bölümünüz',
          studentNo: '000000',
          skills: const [],
          status: 'active',
        );

      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? _buildLoadingScreen() : _buildDashboard(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLoadingScreen() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.secondary),
          const SizedBox(height: 20),
          Text(
            'Yükleniyor...',
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
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
          _buildTopHeader(),

          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomeTab(),
                const ProjectsScreen(),
                const QuizzesScreen(),
                const InternshipRequestsScreen(),
                const OgrenciProfileScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
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
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.person, color: Color(0xFF1ABC9C), size: 30),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _student?.name.isNotEmpty == true ? _student!.name : 'Öğrenci',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _student?.university ?? 'Üniversite',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${_student?.department ?? 'Bölüm'} - ${_student?.studentNo ?? 'Öğrenci No'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
            icon: StreamBuilder<int>(
              stream: _currentUser != null
                  ? _notificationService.streamUnreadCount(_currentUser!.uid)
                  : Stream.value(0),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Stack(
                  children: [
                    const Icon(Icons.notifications, color: Colors.white, size: 28),
                    if (count > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            count > 9 ? '9+' : count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            tooltip: 'Bildirimler',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
            tooltip: 'Yenile',
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: themeProvider.isDarkMode ? 'Açık Tema' : 'Koyu Tema',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF1ABC9C),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 30),
            _buildTalentScoreCard(),
            const SizedBox(height: 30),
            _buildStatisticsSection(),
            const SizedBox(height: 30),
            _buildQuickAccessSection(),
            const SizedBox(height: 30),
            _buildRecentActivity(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emoji_events, color: theme.colorScheme.secondary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoş Geldin!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      'Başarılarını paylaş, yeteneklerini keşfet',
                      style: TextStyle(fontSize: 14, color: theme.textTheme.bodySmall?.color),
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

  // ✅ حاليا ما عندك rating حقيقي من DB، خليها 0 أو اعملها من users إذا حبيت
  Widget _buildTalentScoreCard() {
    final int score = _student?.score ?? 0;

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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text('Puan', style: TextStyle(fontSize: 14, color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
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
                const Text(
                  'Proje Puanı',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bu puan, projelerinize göre otomatik olarak hesaplanmaktadır.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
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
    final theme = Theme.of(context);
    // إذا بدك توصلها من DB لاحقاً، هون مكانها
    const portfolioCount = '0';
    const completedProjects = '0';
    const views = '0';
    const connections = '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 İstatistiklerim',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                title: 'Portföy',
                value: portfolioCount,
                icon: Icons.assignment,
                color: const Color(0xFF3498DB),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                title: 'Projeler',
                value: completedProjects,
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
                value: views,
                icon: Icons.remove_red_eye,
                color: const Color(0xFFE74C3C),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                title: 'Bağlantı',
                value: connections,
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🚀 Hızlı Erişim',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
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
              onTap: () => setState(() => _selectedIndex = 2),
            ),
            _buildQuickAccessButton(
              title: 'Projelerim',
              icon: Icons.folder,
              color: const Color(0xFF1ABC9C),
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            _buildQuickAccessButton(
              title: 'Profilim',
              icon: Icons.person,
              color: const Color(0xFFE74C3C),
              onTap: () => setState(() => _selectedIndex = 3),
            ),
            _buildQuickAccessButton(
              title: 'Şirketler',
              icon: Icons.business,
              color: const Color(0xFF9B59B6),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Şirketler sayfası yakında eklenecek')),
                );
              },
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📝 Son Aktivite',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2),
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
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projeler'),
        BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quizler'),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Stajlar'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: theme.colorScheme.secondary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      showUnselectedLabels: true,
      backgroundColor: theme.colorScheme.surface,
      elevation: 10,
      onTap: _onItemTapped,
    );
  }

  String _getTalentLevel(double score) {
    if (score >= 9) return 'Uzman Seviye';
    if (score >= 7) return 'İleri Seviye';
    if (score >= 5) return 'Orta Seviye';
    if (score >= 3) return 'Başlangıç Seviye';
    return 'Yeni Başladı';
  }
}
