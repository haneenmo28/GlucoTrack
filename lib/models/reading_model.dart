import 'package:cloud_firestore/cloud_firestore.dart';

class ReadingModel {
  final String? id;
  final double glucoseLevel; // ده اللي بنستخدمه للقيمة
  final DateTime timestamp; // ده اللي بنستخدمه للتاريخ
  final String note;
  final String? userId;
  final bool isFasting;

  ReadingModel({
    this.id,
    required this.glucoseLevel,
    required this.timestamp,
    required this.note,
    this.userId,
    required this.isFasting,
  });

  factory ReadingModel.fromMap(Map<String, dynamic> data, String docId) {
    return ReadingModel(
      id: docId,
      glucoseLevel: (data['glucoseLevel'] ?? 0.0).toDouble(),
      timestamp: data['timestamp'] == null
          ? DateTime.now()
          : (data['timestamp'] is Timestamp
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now()),
      note: data['note'] ?? '',
      userId: data['userId'],
      isFasting: data['isFasting'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'glucoseLevel': glucoseLevel,
      'timestamp':
          Timestamp.fromDate(timestamp), // تحويل لـ Timestamp عشان فايربيز
      'note': note,
      'userId': userId,
      'isFasting': isFasting,
    };
  }

  String get status {
    if (isFasting) {
      if (glucoseLevel < 70) return "منخفض";
      if (glucoseLevel <= 100) return "مثالي";
      if (glucoseLevel <= 125) return "ما قبل السكري";
      return "مرتفع";
    } else {
      if (glucoseLevel < 70) return "منخفض";
      if (glucoseLevel <= 140) return "مثالي";
      if (glucoseLevel <= 199) return "ما قبل السكري";
      return "مرتفع";
    }
  }
}
