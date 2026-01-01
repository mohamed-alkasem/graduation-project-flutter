// lib/screens/sirket/internship_requests_list_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/internship_request_model.dart';
import '../../core/services/internship_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import 'add_internship_request_screen.dart';
import 'internship_applications_screen.dart';

class InternshipRequestsListScreen extends StatefulWidget {
  const InternshipRequestsListScreen({super.key});

  @override
  State<InternshipRequestsListScreen> createState() => _InternshipRequestsListScreenState();
}

class _InternshipRequestsListScreenState extends State<InternshipRequestsListScreen> {
  final _internshipService = InternshipService();
  String? _companyId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _companyId = user?.uid;
  }

  Future<void> _deleteRequest(InternshipRequestModel request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı Sil'),
        content: Text('${request.title} ilanını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && request.id != null) {
      try {
        await _internshipService.deleteInternshipRequest(request.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('İlan silindi')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Staj İlanlarım'),
        backgroundColor: const Color(0xFFE74C3C),
      ),
      body: _companyId == null
          ? const Center(child: Text('Lütfen giriş yapın'))
          : StreamBuilder<List<InternshipRequestModel>>(
              stream: _internshipService.streamCompanyInternshipRequests(_companyId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }

                final requests = snapshot.data ?? [];

                if (requests.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.work_off,
                    title: 'Henüz staj ilanı eklenmemiş',
                    subtitle: 'Yeni staj ilanı ekleyerek öğrencilere ulaşın',
                    action: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddInternshipRequestScreen()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('YENİ İLAN EKLE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  color: const Color(0xFFE74C3C),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      return _buildRequestCard(requests[index]);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddInternshipRequestScreen()),
          );
        },
        backgroundColor: const Color(0xFFE74C3C),
        icon: const Icon(Icons.add),
        label: const Text('Yeni İlan'),
      ),
    );
  }

  Widget _buildRequestCard(InternshipRequestModel request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'applications',
                      child: const Row(
                        children: [
                          Icon(Icons.people, size: 20),
                          SizedBox(width: 8),
                          Text('Başvuruları Görüntüle'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Düzenle'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Sil', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'applications' && request.id != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InternshipApplicationsScreen(requestId: request.id!),
                        ),
                      );
                    } else if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddInternshipRequestScreen(request: request),
                        ),
                      );
                    } else if (value == 'delete') {
                      _deleteRequest(request);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.category.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFE74C3C),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: request.isOpen
                        ? const Color(0xFF2ECC71).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.isOpen ? 'Açık' : 'Kapalı',
                    style: TextStyle(
                      color: request.isOpen ? const Color(0xFF2ECC71) : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              request.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF7F8C8D)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(Icons.location_on, request.location),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.schedule,
                  'Son: ${request.applicationDeadline.day}/${request.applicationDeadline.month}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF7F8C8D)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
        ),
      ],
    );
  }
}

