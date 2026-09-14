import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reading_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addReading(ReadingModel reading) async {
    try {
      final String? userId = _auth.currentUser?.uid;

      if (userId != null) {
        Map<String, dynamic> data = reading.toMap();
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
      print("Firestore Error: $error");
      return <ReadingModel>[];
    });
  }

  Future<void> deleteReading(String docId) async {
    try {
      await _firestore.collection('readings').doc(docId).delete();
    } catch (e) {
      print("Error deleting reading: $e");
      rethrow;
    }
  }
}
