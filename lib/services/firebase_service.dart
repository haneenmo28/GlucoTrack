import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reading_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // إضافة قراءة جديدة
  Future<void> addReading(ReadingModel reading) async {
    try {
      final String? userId = _auth.currentUser?.uid;

      if (userId != null) {
        // بنستخدم الـ toMap اللي جوه الموديل عشان نضمن تنسيق الداتا صح
        Map<String, dynamic> data = reading.toMap();

        // تأكيد إن الـ userId مبعوث مع الداتا
        data['userId'] = userId;

        await _firestore.collection('readings').add(data);
      } else {
        throw Exception("User not logged in");
      }
    } catch (e) {
      print("Error adding reading: $e");
      rethrow;
    }
  }

  // جلب القراءات الخاصة بالمستخدم الحالي فقط
  Stream<List<ReadingModel>> getReadings() {
    final String? userId = _auth.currentUser?.uid;

    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('readings')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());
        return ReadingModel.fromMap(data, doc.id);
      }).toList();
    }).handleError((error) {
      // حطينا دي عشان لو الفايربيز طلب Index يطلعلك رسالة واضحة في الـ Console
      print("Firestore Error: $error");
      return <ReadingModel>[];
    });
  }

  // وظيفة حذف قراءة معينة باستخدام الـ ID الخاص بها
  Future<void> deleteReading(String docId) async {
    try {
      await _firestore.collection('readings').doc(docId).delete();
    } catch (e) {
      print("Error deleting reading: $e");
      rethrow;
    }
  }
}
