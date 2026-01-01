// lib/core/services/notification_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const Duration _timeoutDuration = Duration(seconds: 15);

  // Send notification
  Future<String> sendNotification(NotificationModel notification) async {
    try {
      final docRef = await _firestore
          .collection('notifications')
          .add(notification.toMap(isUpdate: false))
          .timeout(_timeoutDuration);
      
      return docRef.id;
    } catch (e) {
      print('Bildirim gönderme hatası: $e');
      throw Exception('Bildirim gönderilemedi: ${e.toString()}');
    }
  }

  // Get notifications for a user
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(_timeoutDuration);

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Bildirimler getirme hatası: $e');
      return [];
    }
  }

  // Stream notifications for real-time updates
  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isRead': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(_timeoutDuration);
    } catch (e) {
      print('Bildirim okundu işaretleme hatası: $e');
      throw Exception('Bildirim güncellenemedi: ${e.toString()}');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get()
          .timeout(_timeoutDuration);

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit().timeout(_timeoutDuration);
    } catch (e) {
      print('Tüm bildirimler okundu işaretleme hatası: $e');
      throw Exception('Bildirimler güncellenemedi: ${e.toString()}');
    }
  }

  // Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get()
          .timeout(_timeoutDuration);

      return querySnapshot.docs.length;
    } catch (e) {
      print('Okunmamış bildirim sayısı hatası: $e');
      return 0;
    }
  }

  // Stream unread count
  Stream<int> streamUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete()
          .timeout(_timeoutDuration);
    } catch (e) {
      print('Bildirim silme hatası: $e');
      throw Exception('Bildirim silinemedi: ${e.toString()}');
    }
  }
}

