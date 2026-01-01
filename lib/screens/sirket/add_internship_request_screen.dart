// lib/screens/sirket/add_internship_request_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/internship_request_model.dart';
import '../../core/services/internship_service.dart';
import '../../core/firebase/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class AddInternshipRequestScreen extends StatefulWidget {
  final InternshipRequestModel? request; // null = add, not null = edit

  const AddInternshipRequestScreen({super.key, this.request});

  @override
  State<AddInternshipRequestScreen> createState() => _AddInternshipRequestScreenState();
}

class _AddInternshipRequestScreenState extends State<AddInternshipRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _internshipService = InternshipService();
  final _authService = AuthService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _documentsController = TextEditingController();
  final TextEditingController _maxApplicationsController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _deadlineDate;
  String? _selectedCategory;
  bool _isLoading = false;
  String? _companyName;

  final List<String> _categories = [
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
    _loadCompanyData();
    if (widget.request != null) {
      _titleController.text = widget.request!.title;
      _descriptionController.text = widget.request!.description;
      _selectedCategory = widget.request!.category;
      _locationController.text = widget.request!.location;
      _requirementsController.text = widget.request!.requirements.join(', ');
      _documentsController.text = widget.request!.requiredDocuments.join(', ');
      _startDate = widget.request!.startDate;
      _endDate = widget.request!.endDate;
      _deadlineDate = widget.request!.applicationDeadline;
      if (widget.request!.maxApplications != null) {
        _maxApplicationsController.text = widget.request!.maxApplications.toString();
      }
    }
  }

  Future<void> _loadCompanyData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      setState(() {
        _companyName = userData?.companyName ?? 'Şirket';
      });
    }
  }

  Future<void> _selectDate(String type) async {
    DateTime? initialDate;
    if (type == 'start') {
      initialDate = _startDate ?? DateTime.now();
    } else if (type == 'end') {
      initialDate = _endDate ?? DateTime.now().add(const Duration(days: 30));
    } else {
      initialDate = _deadlineDate ?? DateTime.now().add(const Duration(days: 7));
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (type == 'start') {
          _startDate = picked;
        } else if (type == 'end') {
          _endDate = picked;
        } else {
          _deadlineDate = picked;
        }
      });
    }
  }

  Future<void> _saveRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen kategori seçin')),
      );
      return;
    }
    if (_startDate == null || _endDate == null || _deadlineDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm tarihleri seçin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      final requirements = _requirementsController.text
          .split(',')
          .map((r) => r.trim())
          .where((r) => r.isNotEmpty)
          .toList();

      final documents = _documentsController.text
          .split(',')
          .map((d) => d.trim())
          .where((d) => d.isNotEmpty)
          .toList();

      int? maxApps;
      if (_maxApplicationsController.text.trim().isNotEmpty) {
        maxApps = int.tryParse(_maxApplicationsController.text);
      }

      final request = InternshipRequestModel(
        id: widget.request?.id,
        companyId: user.uid,
        companyName: _companyName ?? 'Şirket',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        location: _locationController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        applicationDeadline: _deadlineDate!,
        requirements: requirements,
        requiredDocuments: documents,
        maxApplications: maxApps,
        createdAt: widget.request?.createdAt ?? DateTime.now(),
      );

      if (widget.request == null) {
        await _internshipService.addInternshipRequest(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staj ilanı başarıyla eklendi')),
          );
        }
      } else {
        await _internshipService.updateInternshipRequest(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staj ilanı başarıyla güncellendi')),
          );
        }
      }

      if (mounted) {
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
        title: Text(widget.request == null ? 'Yeni Staj İlanı Ekle' : 'Staj İlanı Düzenle'),
        backgroundColor: const Color(0xFFE74C3C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'İlan Başlığı *',
                prefixIcon: Icons.work,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen ilan başlığı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori *',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kategori seçin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _locationController,
                label: 'Konum/Şehir *',
                prefixIcon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen konum girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Açıklama *',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen açıklama girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Requirements
              TextFormField(
                controller: _requirementsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Gereksinimler (virgülle ayırın)',
                  hintText: 'Örnek: Flutter bilgisi, İngilizce, Takım çalışması',
                  prefixIcon: const Icon(Icons.checklist),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Required Documents
              TextFormField(
                controller: _documentsController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'İstenen Belgeler (virgülle ayırın)',
                  hintText: 'Örnek: CV, Portföy, Diploma',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Start Date
              InkWell(
                onTap: () => _selectDate('start'),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Başlangıç Tarihi *',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  child: Text(
                    _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Tarih seçin',
                    style: TextStyle(
                      color: _startDate != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // End Date
              InkWell(
                onTap: () => _selectDate('end'),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Bitiş Tarihi *',
                    prefixIcon: const Icon(Icons.event),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  child: Text(
                    _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'Tarih seçin',
                    style: TextStyle(
                      color: _endDate != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Deadline
              InkWell(
                onTap: () => _selectDate('deadline'),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Son Başvuru Tarihi *',
                    prefixIcon: const Icon(Icons.schedule),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  child: Text(
                    _deadlineDate != null
                        ? '${_deadlineDate!.day}/${_deadlineDate!.month}/${_deadlineDate!.year}'
                        : 'Tarih seçin',
                    style: TextStyle(
                      color: _deadlineDate != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _maxApplicationsController,
                label: 'Maksimum Başvuru Sayısı (opsiyonel)',
                prefixIcon: Icons.people,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),

              GradientButton(
                text: widget.request == null ? 'İLAN EKLE' : 'GÜNCELLE',
                onPressed: _saveRequest,
                isLoading: _isLoading,
                gradient: const LinearGradient(
                  colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
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
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _requirementsController.dispose();
    _documentsController.dispose();
    _maxApplicationsController.dispose();
    super.dispose();
  }
}

