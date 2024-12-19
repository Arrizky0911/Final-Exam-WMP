import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  final String id;
  final String name;
  final String code;
  final int credits;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.credits,
  });

  factory Subject.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Subject(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      credits: data['credits'] ?? 0,
    );
  }
}

