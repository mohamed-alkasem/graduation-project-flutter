// lib/screens/ogrenci/apply_internship_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/internship_request_model.dart';
import '../../core/services/internship_service.dart';
import '../../core/firebase/storage_service.dart';
import '../../core/firebase/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class ApplyInternshipScreen extends StatefulWidget {
  final InternshipRequestModel request;

  const ApplyInternshipScreen({super.key, required this.request});

  @override
  State<ApplyInternshipScreen> createState() => _ApplyInternshipScreenState();
}

class _ApplyInternshipScreenState extends State<ApplyInternshipScreen> {
  final _formKey = GlobalKey<FormState>();
  final _internshipService = InternshipService();
  final _storageService = StorageService();
  final _authService = AuthService();
  final _imagePicker = ImagePicker();

  final TextEditingController _coverLetterController = TextEditingController();
  
  Map<String, File> _uploadedFiles = {}; // documentType -> File
  bool _isLoading = false;
  String? _studentName;
  String? _studentEmail;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      setState(() {
        _studentName = userData?.name ?? '';
        _studentEmail = userData?.email ?? '';
      });
    }
  }

  Future<void> _pickFile(String documentType) async {
    // For now, using image picker - can be extended to use file_picker package
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _uploadedFiles[documentType] = File(pickedFile.path);
      });
    }
  }

  void _removeFile(String documentType) {
    setState(() {
      _uploadedFiles.remove(documentType);
    });
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen giriş yapın')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload files
      Map<String, String> uploadedDocuments = {};
      for (var entry in _uploadedFiles.entries) {
        final fileUrl = await _storageService.uploadInternshipFile(
          entry.value,
          user.uid,
          widget.request.id!,
          entry.key,
        );
        uploadedDocuments[entry.key] = fileUrl;
      }

      final application = InternshipApplicationModel(
        internshipRequestId: widget.request.id!,
        studentId: user.uid,
        studentName: _studentName ?? '',
        studentEmail: _studentEmail ?? '',
        coverLetter: _coverLetterController.text.trim().isEmpty 
            ? null 
            : _coverLetterController.text.trim(),
        uploadedDocuments: uploadedDocuments.isEmpty ? null : uploadedDocuments,
        createdAt: DateTime.now(),
      );

      await _internshipService.applyForInternship(application);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Başvurunuz başarıyla gönderildi')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Staj Başvurusu'),
        backgroundColor: const Color(0xFF1ABC9C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Request Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1ABC9C)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.request.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.request.companyName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cover Letter
              TextFormField(
                controller: _coverLetterController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Ön Yazı (Opsiyonel)',
                  hintText: 'Kendiniz ve neden bu pozisyona uygun olduğunuz hakkında yazın...',
                  prefixIcon: const Icon(Icons.edit_note),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Required Documents
              const Text(
                'İstenen Belgeler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),

              if (widget.request.requiredDocuments.isEmpty)
                const Text(
                  'Bu ilan için belge gerekmiyor',
                  style: TextStyle(color: Color(0xFF7F8C8D)),
                )
              else
                ...widget.request.requiredDocuments.map((docType) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.description, color: Color(0xFF1ABC9C)),
                            const SizedBox(width: 8),
                            Text(
                              docType,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const Spacer(),
                            if (_uploadedFiles.containsKey(docType))
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeFile(docType),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_uploadedFiles.containsKey(docType))
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ECC71).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _uploadedFiles[docType]!.path.split('/').last,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2ECC71),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () => _pickFile(docType),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Dosya Yükle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1ABC9C),
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),

              const SizedBox(height: 30),

              GradientButton(
                text: 'BAŞVURUYU GÖNDER',
                onPressed: _submitApplication,
                isLoading: _isLoading,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1ABC9C), Color(0xFF16A085)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }
}

