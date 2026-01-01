// lib/core/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? id;
  String recipientId; // الطالب الذي سيستقبل الإشعار
  String senderId; // الشركة المرسلة
  String senderName; // اسم الشركة
  String title; // عنوان الإشعار
  String message; // الرسالة
  String type; // 'message', 'application_status', 'internship_offer', etc.
  bool isRead; // تم القراءة
  DateTime createdAt;

  NotificationModel({
    this.id,
    required this.recipientId,
    required this.senderId,
    required this.senderName,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    final created = _parseDate(map['createdAt']) ?? DateTime.now();

    return NotificationModel(
      id: id,
      recipientId: map['recipientId']?.toString() ?? '',
      senderId: map['senderId']?.toString() ?? '',
      senderName: map['senderName']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      type: map['type']?.toString() ?? 'message',
      isRead: map['isRead'] as bool? ?? false,
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    final data = <String, dynamic>{
      'recipientId': recipientId,
      'senderId': senderId,
      'senderName': senderName.trim(),
      'title': title.trim(),
      'message': message.trim(),
      'type': type,
      'isRead': isRead,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!isUpdate) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    return data;
  }
}

