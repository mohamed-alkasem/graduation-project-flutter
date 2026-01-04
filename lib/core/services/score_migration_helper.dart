// lib/core/services/score_migration_helper.dart
// Bu dosya, mevcut öğrencilerin score'larını hesaplamak için kullanılır
// Bir kere çalıştırılmalıdır (örn: admin paneli veya Cloud Function'dan)

import '../services/project_service.dart';

class ScoreMigrationHelper {
  final ProjectService _projectService = ProjectService();

  /// Tüm öğrencilerin score'larını hesapla ve güncelle
  /// Bu fonksiyon bir kere çalıştırılmalıdır
  Future<void> migrateAllStudentsScores() async {
    try {
      print('🔄 Score migration başlatılıyor...');
      await _projectService.updateAllStudentsScores();
      print('✅ Score migration tamamlandı!');
    } catch (e) {
      print('❌ Score migration hatası: $e');
      rethrow;
    }
  }
}

