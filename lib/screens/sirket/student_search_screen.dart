// lib/screens/sirket/student_search_screen.dart
import 'package:flutter/material.dart';
import '../../core/services/student_search_service.dart';
import '../../core/models/user_model.dart';
import '../../core/models/project_model.dart';
import 'student_detail_screen.dart';

class StudentSearchScreen extends StatefulWidget {
  const StudentSearchScreen({super.key});

  @override
  State<StudentSearchScreen> createState() => _StudentSearchScreenState();
}

class _StudentSearchScreenState extends State<StudentSearchScreen> {
  final _searchService = StudentSearchService();
  final _searchController = TextEditingController();

  List<StudentSearchResult> _results = [];
  List<String> _departments = [];
  List<String> _skills = [];
  bool _isLoading = false;
  bool _isLoadingFilters = true;

  String? _selectedDepartment;
  String? _selectedSkill;
  String? _selectedProjectType;

  final List<String> _projectTypes = [
    'tümü',
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
    _loadFilters();
    _performSearch(); // Load all students initially
  }

  Future<void> _loadFilters() async {
    setState(() => _isLoadingFilters = true);
    try {
      final departments = await _searchService.getUniqueDepartments();
      final skills = await _searchService.getUniqueSkills();
      setState(() {
        _departments = ['tümü', ...departments];
        _skills = ['tümü', ...skills];
        _isLoadingFilters = false;
      });
    } catch (e) {
      setState(() => _isLoadingFilters = false);
    }
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);

    try {
      final results = await _searchService.searchStudents(
        department: _selectedDepartment == 'tümü' ? null : _selectedDepartment,
        skill: _selectedSkill == 'tümü' ? null : _selectedSkill,
        projectType: _selectedProjectType == 'tümü' ? null : _selectedProjectType,
        searchQuery: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      );

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Arama hatası: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Öğrenci Ara'),
        backgroundColor: const Color(0xFFE74C3C),
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'İsim, üniversite veya bölüm ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _searchController.clear());
                              _performSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onSubmitted: (_) => _performSearch(),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),

                // Filters
                if (_isLoadingFilters)
                  const Center(child: CircularProgressIndicator())
                else
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterDropdown(
                          'Bölüm',
                          _selectedDepartment,
                          _departments,
                          (value) {
                            setState(() => _selectedDepartment = value);
                            _performSearch();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFilterDropdown(
                          'Yetenek',
                          _selectedSkill,
                          _skills,
                          (value) {
                            setState(() => _selectedSkill = value);
                            _performSearch();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFilterDropdown(
                          'Proje Tipi',
                          _selectedProjectType,
                          _projectTypes,
                          (value) {
                            setState(() => _selectedProjectType = value);
                            _performSearch();
                          },
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Ara'),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _performSearch,
                        color: const Color(0xFFE74C3C),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            return _buildStudentCard(_results[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value ?? items.first,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item == 'tümü' ? 'Tümü' : item,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            'Öğrenci bulunamadı',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Farklı filtreler deneyin',
            style: TextStyle(color: Color(0xFF7F8C8D)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(StudentSearchResult result) {
    final student = result.student;
    final projects = result.projects;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDetailScreen(student: student),
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
                  // Profile Image
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFE74C3C).withOpacity(0.1),
                    child: const Icon(Icons.person, size: 30, color: Color(0xFFE74C3C)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (student.university != null)
                          Text(
                            student.university!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        if (student.department != null)
                          Text(
                            student.department!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1ABC9C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF7F8C8D)),
                ],
              ),
              const SizedBox(height: 12),

              // Skills
              if (student.skills != null && student.skills!.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: student.skills!.take(5).map((skill) {
                    return Chip(
                      label: Text(skill, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.grey[200],
                      padding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Projects Count and Score
              Row(
                children: [
                  const Icon(Icons.folder, size: 16, color: Color(0xFF1ABC9C)),
                  const SizedBox(width: 8),
                  Text(
                    '${projects.length} Proje',
                    style: const TextStyle(
                      color: Color(0xFF1ABC9C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.star, size: 16, color: Color(0xFFF39C12)),
                  const SizedBox(width: 4),
                  Text(
                    '${student.score} Puan',
                    style: const TextStyle(
                      color: Color(0xFFF39C12),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

