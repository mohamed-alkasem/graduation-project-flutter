// lib/screens/ogrenci/add_edit_project_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/project_model.dart';
import '../../core/services/project_service.dart';
import '../../core/firebase/storage_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class AddEditProjectScreen extends StatefulWidget {
  final ProjectModel? project; // null = add, not null = edit

  const AddEditProjectScreen({super.key, this.project});

  @override
  State<AddEditProjectScreen> createState() => _AddEditProjectScreenState();
}

class _AddEditProjectScreenState extends State<AddEditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectService = ProjectService();
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _githubUrlController = TextEditingController();
  final TextEditingController _liveUrlController = TextEditingController();
  final TextEditingController _technologiesController = TextEditingController();

  String? _selectedProjectType;
  List<File> _selectedImages = [];
  List<String> _existingImageUrls = []; // For editing
  bool _isLoading = false;

  final List<String> _projectTypes = [
    'web',
    'mobil',
    'masaüstü',
    'yapay zeka',
    'oyun',
    'veri bilimi',
    'ağ ve güvenlik',
    'diğer',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      // Edit mode
      _titleController.text = widget.project!.title;
      _descriptionController.text = widget.project!.description;
      _selectedProjectType = widget.project!.projectType;
      _githubUrlController.text = widget.project!.githubUrl ?? '';
      _liveUrlController.text = widget.project!.liveUrl ?? '';
      _existingImageUrls = List<String>.from(widget.project!.images);
      if (widget.project!.technologies != null) {
        _technologiesController.text = widget.project!.technologies!.join(', ');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.project == null ? 'Yeni Proje Ekle' : 'Projeyi Düzenle'),
        backgroundColor: const Color(0xFF1ABC9C),
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
                label: 'Proje Başlığı *',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen proje başlığı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Project Type
              DropdownButtonFormField<String>(
                value: _selectedProjectType,
                decoration: InputDecoration(
                  labelText: 'Proje Tipi *',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _projectTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedProjectType = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen proje tipi seçin';
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
                  labelText: 'Proje Açıklaması *',
                  hintText: 'Projeniz hakkında detaylı bilgi verin',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen proje açıklaması girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _githubUrlController,
                label: 'GitHub URL',
                prefixIcon: Icons.code,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _liveUrlController,
                label: 'Canlı Demo URL',
                prefixIcon: Icons.link,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _technologiesController,
                decoration: InputDecoration(
                  labelText: 'Teknolojiler (virgülle ayırın)',
                  hintText: 'Örnek: Flutter, Firebase, Dart',
                  prefixIcon: const Icon(Icons.build),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Images Section
              const Text(
                'Proje Görselleri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),

              // Existing images (for edit mode)
              if (_existingImageUrls.isNotEmpty) ...[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _existingImageUrls.map((url) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -5,
                          right: -5,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() => _existingImageUrls.remove(url));
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Selected images
              if (_selectedImages.isNotEmpty) ...[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _selectedImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final image = entry.value;
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(image, fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: -5,
                          right: -5,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() => _selectedImages.removeAt(index));
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Resim Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1ABC9C),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(height: 30),

              GradientButton(
                text: widget.project == null ? 'PROJE EKLE' : 'GÜNCELLE',
                onPressed: _saveProject,
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

  Future<void> _pickImages() async {
    final pickedFiles = await _imagePicker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen proje tipi seçin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      // Upload new images
      List<String> newImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final projectId = widget.project?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        for (var image in _selectedImages) {
          final url = await _storageService.uploadProjectImage(image, user.uid, projectId);
          newImageUrls.add(url);
        }
      }

      // Combine existing and new image URLs
      final allImageUrls = [..._existingImageUrls, ...newImageUrls];

      // Parse technologies
      List<String>? technologies;
      if (_technologiesController.text.trim().isNotEmpty) {
        technologies = _technologiesController.text
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList();
      }

      final project = ProjectModel(
        id: widget.project?.id,
        userId: user.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        projectType: _selectedProjectType!,
        githubUrl: _githubUrlController.text.trim().isEmpty ? null : _githubUrlController.text.trim(),
        liveUrl: _liveUrlController.text.trim().isEmpty ? null : _liveUrlController.text.trim(),
        images: allImageUrls,
        technologies: technologies,
        createdAt: widget.project?.createdAt ?? DateTime.now(),
      );

      if (widget.project == null) {
        // Add new project
        await _projectService.addProject(project);
      } else {
        // Update existing project
        await _projectService.updateProject(project);
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _githubUrlController.dispose();
    _liveUrlController.dispose();
    _technologiesController.dispose();
    super.dispose();
  }
}

