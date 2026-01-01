// lib/screens/sirket/quizzes_list_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/quiz_model.dart';
import '../../core/services/quiz_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/gradient_button.dart';
import 'add_quiz_screen.dart';
import '../../widgets/loading_widget.dart';

class QuizzesListScreen extends StatefulWidget {
  const QuizzesListScreen({super.key});

  @override
  State<QuizzesListScreen> createState() => _QuizzesListScreenState();
}

class _QuizzesListScreenState extends State<QuizzesListScreen> {
  final _quizService = QuizService();
  List<QuizModel> _quizzes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final quizzes = await _quizService.getCompanyQuizzes(user.uid);
      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteQuiz(QuizModel quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Sil'),
        content: Text('${quiz.title} quizini silmek istediğinize emin misiniz?'),
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

    if (confirmed == true && quiz.id != null) {
      try {
        await _quizService.deleteQuiz(quiz.id!);
        _loadQuizzes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz silindi')),
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
        title: const Text('Quizlerim'),
        backgroundColor: const Color(0xFFE74C3C),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _quizzes.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.quiz,
                  title: 'Henüz quiz eklenmemiş',
                  subtitle: 'Yeni quiz ekleyerek öğrencileri test edin',
                  action: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddQuizScreen()),
                      );
                      if (result == true) {
                        _loadQuizzes();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('YENİ QUIZ EKLE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadQuizzes,
                  color: const Color(0xFFE74C3C),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _quizzes.length,
                    itemBuilder: (context, index) {
                      return _buildQuizCard(_quizzes[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddQuizScreen()),
          );
          if (result == true) {
            _loadQuizzes();
          }
        },
        backgroundColor: const Color(0xFFE74C3C),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Quiz'),
      ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz) {
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
                    quiz.title,
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
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddQuizScreen(quiz: quiz),
                        ),
                      ).then((result) {
                        if (result == true) {
                          _loadQuizzes();
                        }
                      });
                    } else if (value == 'delete') {
                      _deleteQuiz(quiz);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                quiz.category.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFE74C3C),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              quiz.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF7F8C8D)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  Icons.access_time,
                  '${quiz.durationMinutes} dk',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.calendar_today,
                  '${quiz.startDate.day}/${quiz.startDate.month} - ${quiz.endDate.day}/${quiz.endDate.month}',
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: quiz.isOpen
                        ? const Color(0xFF2ECC71).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    quiz.isOpen ? 'Aktif' : 'Kapalı',
                    style: TextStyle(
                      color: quiz.isOpen ? const Color(0xFF2ECC71) : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
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


