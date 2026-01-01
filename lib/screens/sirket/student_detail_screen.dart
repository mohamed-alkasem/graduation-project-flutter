// lib/screens/sirket/student_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/user_model.dart';
import '../../core/services/project_service.dart';
import '../../core/models/project_model.dart';
import 'send_message_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final UserModel student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final _projectService = ProjectService();

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('URL açılamadı')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Öğrenci Detayları'),
        backgroundColor: const Color(0xFFE74C3C),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SendMessageScreen(student: student),
                ),
              );
            },
            icon: const Icon(Icons.message),
            tooltip: 'Mesaj Gönder',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFE74C3C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.person, size: 50, color: Color(0xFFE74C3C)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (student.university != null)
                    Text(
                      student.university!,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  if (student.department != null)
                    Text(
                      student.department!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Information
                  _buildSection(
                    'İletişim Bilgileri',
                    Icons.contact_mail,
                    [
                      if (student.email.isNotEmpty)
                        _buildInfoRow(Icons.email, 'E-posta', student.email),
                      if (student.phone != null && student.phone!.isNotEmpty)
                        _buildInfoRow(Icons.phone, 'Telefon', student.phone!),
                      if (student.studentNo != null && student.studentNo!.isNotEmpty)
                        _buildInfoRow(Icons.badge, 'Öğrenci No', student.studentNo!),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Skills
                  if (student.skills != null && student.skills!.isNotEmpty)
                    _buildSection(
                      'Yetenekler',
                      Icons.star,
                      [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: student.skills!.map((skill) {
                            return Chip(
                              label: Text(skill),
                              backgroundColor: const Color(0xFFE74C3C).withOpacity(0.1),
                              labelStyle: const TextStyle(color: Color(0xFFE74C3C)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                  if (student.skills != null && student.skills!.isNotEmpty)
                    const SizedBox(height: 24),

                  // Bio
                  if (student.bio != null && student.bio!.trim().isNotEmpty)
                    _buildSection(
                      'Hakkında',
                      Icons.info,
                      [
                        Text(
                          student.bio!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),

                  if (student.bio != null && student.bio!.trim().isNotEmpty)
                    const SizedBox(height: 24),

                  // Projects
                  StreamBuilder<List<ProjectModel>>(
                    stream: widget.student.id != null
                        ? _projectService.streamStudentProjects(widget.student.id!)
                        : null,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildSection(
                          'Projeler',
                          Icons.folder,
                          [const Center(child: CircularProgressIndicator())],
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildSection(
                          'Projeler',
                          Icons.folder,
                          [Text('Hata: ${snapshot.error}')],
                        );
                      }

                      final projects = snapshot.data ?? [];

                      return _buildSection(
                        'Projeler (${projects.length})',
                        Icons.folder,
                        projects.isEmpty
                            ? [
                                const Text(
                                  'Henüz proje eklenmemiş',
                                  style: TextStyle(color: Color(0xFF7F8C8D)),
                                ),
                              ]
                            : projects.map((project) => _buildProjectCard(project)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE74C3C)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF7F8C8D)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1ABC9C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  project.projectType.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF1ABC9C),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Project Images
          if (project.images.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: project.images.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        project.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (project.images.isNotEmpty) const SizedBox(height: 12),

          Text(
            project.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF7F8C8D)),
          ),
          const SizedBox(height: 12),

          // Technologies
          if (project.technologies != null && project.technologies!.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.technologies!.map((tech) {
                return Chip(
                  label: Text(tech, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.grey[200],
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),

          const SizedBox(height: 12),

          // Links
          Row(
            children: [
              if (project.githubUrl != null && project.githubUrl!.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _launchUrl(project.githubUrl!),
                  icon: const Icon(Icons.code, size: 18),
                  label: const Text('GitHub'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2C3E50),
                  ),
                ),
              if (project.liveUrl != null && project.liveUrl!.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _launchUrl(project.liveUrl!),
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Canlı Demo'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1ABC9C),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

