// lib/screens/ogrenci/internship_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/internship_request_model.dart';
import '../../core/services/internship_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/info_card_widget.dart';
import 'apply_internship_screen.dart';

class InternshipRequestsScreen extends StatefulWidget {
  const InternshipRequestsScreen({super.key});

  @override
  State<InternshipRequestsScreen> createState() => _InternshipRequestsScreenState();
}

class _InternshipRequestsScreenState extends State<InternshipRequestsScreen> {
  final _internshipService = InternshipService();
  String? _selectedCategory;

  final List<String> _categories = [
    'tümü',
    'programlama',
    'tasarım',
    'pazarlama',
    'veri bilimi',
    'yapay zeka',
    'web geliştirme',
    'mobil geliştirme',
    'veritabanı',
    'ağ ve güvenlik',
    'diğer',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Staj İlanları'),
        backgroundColor: const Color(0xFF1ABC9C),
      ),
      body: Column(
        children: [
          // Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat == 'tümü' ? 'Tümü' : cat.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
            ),
          ),

          // Requests List
          Expanded(
            child: StreamBuilder<List<InternshipRequestModel>>(
              stream: _internshipService.streamActiveInternshipRequests(
                category: _selectedCategory == 'tümü' ? null : _selectedCategory,
              ),
              builder: (context, snapshot) {
                // Handle loading state
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const LoadingWidget(message: 'Staj ilanları yükleniyor...');
                }

                // Handle error state
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Hata: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Yeniden Dene'),
                        ),
                      ],
                    ),
                  );
                }

                // Get data
                final requests = snapshot.data ?? [];

                // Handle empty state
                if (requests.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.work_off,
                    title: 'Henüz aktif staj ilanı yok',
                    subtitle: 'Yakında yeni ilanlar eklenecektir',
                  );
                }

                // Show list
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  color: const Color(0xFF1ABC9C),
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
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(InternshipRequestModel request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InternshipRequestDetailScreen(request: request),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF7F8C8D)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1ABC9C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      request.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF1ABC9C),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Açık',
                      style: TextStyle(
                        color: Color(0xFF2ECC71),
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
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoRow(Icons.business, request.companyName),
                  _buildInfoRow(Icons.location_on, request.location),
                  _buildInfoRow(
                    Icons.schedule,
                    'Son: ${request.applicationDeadline.day}/${request.applicationDeadline.month}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF7F8C8D)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

// Detail Screen
class InternshipRequestDetailScreen extends StatefulWidget {
  final InternshipRequestModel request;

  const InternshipRequestDetailScreen({super.key, required this.request});

  @override
  State<InternshipRequestDetailScreen> createState() => _InternshipRequestDetailScreenState();
}

class _InternshipRequestDetailScreenState extends State<InternshipRequestDetailScreen> {
  final _internshipService = InternshipService();
  bool _hasApplied = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && widget.request.id != null) {
      final applied = await _internshipService.hasStudentApplied(widget.request.id!, user.uid);
      setState(() {
        _hasApplied = applied;
        _isChecking = false;
      });
    } else {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('İlan Detayları'),
        backgroundColor: const Color(0xFF1ABC9C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoCardWidget(
              title: request.title,
              icon: Icons.work,
              iconColor: const Color(0xFF1ABC9C),
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1ABC9C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        request.category.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF1ABC9C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  request.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7F8C8D),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.business, 'Şirket', request.companyName),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.location_on, 'Konum', request.location),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.calendar_today, 'Başlangıç',
                    '${request.startDate.day}/${request.startDate.month}/${request.startDate.year}'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.event, 'Bitiş',
                    '${request.endDate.day}/${request.endDate.month}/${request.endDate.year}'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.schedule, 'Son Başvuru Tarihi',
                    '${request.applicationDeadline.day}/${request.applicationDeadline.month}/${request.applicationDeadline.year}'),
              ],
            ),
            const SizedBox(height: 24),

            if (request.requirements.isNotEmpty)
              InfoCardWidget(
                title: 'Gereksinimler',
                icon: Icons.checklist,
                iconColor: const Color(0xFF1ABC9C),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: request.requirements.map((req) {
                      return Chip(
                        label: Text(req),
                        backgroundColor: Colors.grey[200],
                      );
                    }).toList(),
                  ),
                ],
              ),
            if (request.requirements.isNotEmpty) const SizedBox(height: 24),

            if (request.requiredDocuments.isNotEmpty)
              InfoCardWidget(
                title: 'İstenen Belgeler',
                icon: Icons.description,
                iconColor: const Color(0xFF1ABC9C),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: request.requiredDocuments.map((doc) {
                      return Chip(
                        label: Text(doc),
                        backgroundColor: Colors.grey[200],
                      );
                    }).toList(),
                  ),
                ],
              ),
            if (request.requiredDocuments.isNotEmpty) const SizedBox(height: 24),

            if (user != null && !_isChecking)
              _hasApplied
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3498DB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF3498DB)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFF3498DB)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Bu ilana zaten başvurdunuz',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ApplyInternshipScreen(request: request),
                          ),
                        );
                        if (result == true) {
                          _checkApplicationStatus();
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('BAŞVUR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1ABC9C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF7F8C8D)),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(text: '$label: '),
                TextSpan(
                  text: value.isEmpty ? 'Belirtilmemiş' : value,
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

