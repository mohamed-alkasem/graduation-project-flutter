// lib/screens/ogrenci/quizzes_screen.dart
import 'package:flutter/material.dart';
import '../../core/models/quiz_model.dart';
import '../../core/services/quiz_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/info_card_widget.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  final _quizService = QuizService();
  List<QuizModel> _quizzes = [];
  bool _isLoading = true;
  String? _selectedCategory;

  final List<String> _categories = [
    'tümü',
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
    _selectedCategory = _categories.first;
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() => _isLoading = true);
    try {
      final quizzes = await _quizService.getActiveQuizzes(
        category: _selectedCategory == 'tümü' ? null : _selectedCategory,
      );
      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Quizler ve Yarışmalar'),
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
                _loadQuizzes();
              },
            ),
          ),

          // Quizzes List
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _quizzes.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.quiz,
                        title: 'Henüz aktif quiz yok',
                        subtitle: 'Yakında yeni quizler eklenecektir',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadQuizzes,
                        color: const Color(0xFF1ABC9C),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _quizzes.length,
                          itemBuilder: (context, index) {
                            return _buildQuizCard(_quizzes[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizDetailScreen(quiz: quiz),
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
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
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
                      quiz.category.toUpperCase(),
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
                      'Aktif',
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
                quiz.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF7F8C8D)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoRow(Icons.business, quiz.companyName),
                  const SizedBox(width: 16),
                  _buildInfoRow(Icons.access_time, '${quiz.durationMinutes} dk'),
                  const SizedBox(width: 16),
                  _buildInfoRow(
                    Icons.calendar_today,
                    '${quiz.endDate.day}/${quiz.endDate.month}/${quiz.endDate.year}',
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

// Quiz Detail Screen (simple for now, will be extended with AI later)
class QuizDetailScreen extends StatelessWidget {
  final QuizModel quiz;

  const QuizDetailScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Quiz Detayları'),
        backgroundColor: const Color(0xFF1ABC9C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoCardWidget(
              title: quiz.title,
              icon: Icons.quiz,
              iconColor: const Color(0xFF1ABC9C),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1ABC9C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    quiz.category.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF1ABC9C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  quiz.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7F8C8D),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.business, 'Şirket', quiz.companyName),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.access_time, 'Süre', '${quiz.durationMinutes} dakika'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.calendar_today, 'Başlangıç',
                    '${quiz.startDate.day}/${quiz.startDate.month}/${quiz.startDate.year}'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.event, 'Bitiş',
                    '${quiz.endDate.day}/${quiz.endDate.month}/${quiz.endDate.year}'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.star, 'Maksimum Puan', '${quiz.maxScore}'),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3498DB)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF3498DB), size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Quiz AI modülü ile otomatik oluşturulacaktır. '
                    'Bu özellik yakında aktif olacaktır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF7F8C8D)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7F8C8D),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

