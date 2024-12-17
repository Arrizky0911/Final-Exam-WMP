import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  final String id;
  final String code;
  final String name;
  final int credits;

  Subject({required this.id, required this.code, required this.name, required this.credits});

  factory Subject.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Subject(
      id: doc.id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      credits: data['credits'] ?? 0,
    );
  }
}

