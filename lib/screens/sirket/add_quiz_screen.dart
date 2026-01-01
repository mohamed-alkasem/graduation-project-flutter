// lib/screens/sirket/add_quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/quiz_model.dart';
import '../../core/services/quiz_service.dart';
import '../../core/firebase/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/empty_state_widget.dart';

class AddQuizScreen extends StatefulWidget {
  final QuizModel? quiz; // null = add, not null = edit

  const AddQuizScreen({super.key, this.quiz});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quizService = QuizService();
  final _authService = AuthService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;
  bool _isLoading = false;
  String? _companyName;

  final List<String> _categories = [
    'programlama',
    'tasarım',
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
    if (widget.quiz != null) {
      _titleController.text = widget.quiz!.title;
      _descriptionController.text = widget.quiz!.description;
      _selectedCategory = widget.quiz!.category;
      _durationController.text = widget.quiz!.durationMinutes.toString();
      _startDate = widget.quiz!.startDate;
      _endDate = widget.quiz!.endDate;
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

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen kategori seçin')),
      );
      return;
    }
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen başlangıç ve bitiş tarihlerini seçin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      final duration = int.tryParse(_durationController.text) ?? 60;

      final quiz = QuizModel(
        id: widget.quiz?.id,
        companyId: user.uid,
        companyName: _companyName ?? 'Şirket',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        questions: widget.quiz?.questions ?? [], // TODO: Will be handled with AI later
        startDate: _startDate!,
        endDate: _endDate!,
        durationMinutes: duration,
        createdAt: widget.quiz?.createdAt ?? DateTime.now(),
      );

      if (widget.quiz == null) {
        await _quizService.addQuiz(quiz);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz başarıyla eklendi')),
          );
        }
      } else {
        await _quizService.updateQuiz(quiz);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz başarıyla güncellendi')),
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
        title: Text(widget.quiz == null ? 'Yeni Quiz Ekle' : 'Quiz Düzenle'),
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
                label: 'Quiz Başlığı *',
                prefixIcon: Icons.quiz,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen quiz başlığı girin';
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

              // Start Date
              InkWell(
                onTap: () => _selectDate(true),
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
                onTap: () => _selectDate(false),
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

              CustomTextField(
                controller: _durationController,
                label: 'Süre (dakika) *',
                prefixIcon: Icons.timer,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen süre girin';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'Geçerli bir süre girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Info about AI
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3498DB)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF3498DB)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sorular AI modülü ile otomatik oluşturulacaktır. '
                        'Bu özellik yakında aktif olacaktır.',
                        style: TextStyle(color: Color(0xFF2C3E50)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              GradientButton(
                text: widget.quiz == null ? 'QUIZ EKLE' : 'GÜNCELLE',
                onPressed: _saveQuiz,
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
    _durationController.dispose();
    super.dispose();
  }
}

