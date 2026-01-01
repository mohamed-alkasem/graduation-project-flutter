// lib/screens/sirket/internship_applications_screen.dart
import 'package:flutter/material.dart';
import '../../core/models/internship_request_model.dart';
import '../../core/services/internship_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/info_card_widget.dart';

class InternshipApplicationsScreen extends StatefulWidget {
  final String requestId;

  const InternshipApplicationsScreen({super.key, required this.requestId});

  @override
  State<InternshipApplicationsScreen> createState() => _InternshipApplicationsScreenState();
}

class _InternshipApplicationsScreenState extends State<InternshipApplicationsScreen> {
  final _internshipService = InternshipService();
  List<InternshipApplicationModel> _applications = [];
  InternshipRequestModel? _request;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _request = await _internshipService.getInternshipRequestById(widget.requestId);
      _applications = await _internshipService.getApplicationsForRequest(widget.requestId);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateApplicationStatus(String applicationId, String status) async {
    try {
      await _internshipService.updateApplicationStatus(applicationId, status);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Başvuru durumu güncellendi: ${status == 'accepted' ? 'Kabul Edildi' : 'Reddedildi'}')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_request?.title ?? 'Başvurular'),
        backgroundColor: const Color(0xFFE74C3C),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _applications.isEmpty
              ? const Center(
                  child: Text(
                    'Henüz başvuru yok',
                    style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: const Color(0xFFE74C3C),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _applications.length,
                    itemBuilder: (context, index) {
                      return _buildApplicationCard(_applications[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildApplicationCard(InternshipApplicationModel application) {
    Color statusColor;
    String statusText;
    switch (application.status) {
      case 'accepted':
        statusColor = const Color(0xFF2ECC71);
        statusText = 'Kabul Edildi';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Reddedildi';
        break;
      default:
        statusColor = const Color(0xFFF39C12);
        statusText = 'Beklemede';
    }

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.studentName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        application.studentEmail,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (application.coverLetter != null && application.coverLetter!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Ön Yazı:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                application.coverLetter!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ],
            if (application.uploadedDocuments != null && application.uploadedDocuments!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Yüklenen Belgeler:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: application.uploadedDocuments!.entries.map((entry) {
                  return Chip(
                    label: Text(entry.key),
                    backgroundColor: Colors.grey[200],
                  );
                }).toList(),
              ),
            ],
            if (application.status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateApplicationStatus(application.id!, 'accepted'),
                      icon: const Icon(Icons.check),
                      label: const Text('Kabul Et'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateApplicationStatus(application.id!, 'rejected'),
                      icon: const Icon(Icons.close),
                      label: const Text('Reddet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

