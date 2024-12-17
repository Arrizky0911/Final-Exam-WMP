import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/subject.dart';

class EnrollmentSummaryScreen extends StatefulWidget {
  const EnrollmentSummaryScreen({super.key});

  @override
  State<EnrollmentSummaryScreen> createState() => _EnrollmentSummaryScreenState();
}

class _EnrollmentSummaryScreenState extends State<EnrollmentSummaryScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<Subject> _enrolledSubjects = [];
  int _totalCredits = 0;

  @override
  void initState() {
    super.initState();
    _loadEnrolledSubjects();
  }

  Future<void> _loadEnrolledSubjects() async {
    final userId = _auth.currentUser!.uid;
    final enrollmentsSnapshot = await _firestore
        .collection('enrollments')
        .where('student_id', isEqualTo: userId)
        .get();

    final subjectIds = enrollmentsSnapshot.docs.map((doc) => doc['subject_id'] as String).toList();

    final subjectsSnapshot = await _firestore
        .collection('subjects')
        .where(FieldPath.documentId, whereIn: subjectIds)
        .get();

    setState(() {
      _enrolledSubjects = subjectsSnapshot.docs
          .map((doc) => Subject.fromFirestore(doc))
          .toList();
      _totalCredits = _enrolledSubjects.fold(0, (sum, subject) => sum + subject.credits);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enrollment Summary')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _enrolledSubjects.length,
              itemBuilder: (context, index) {
                final subject = _enrolledSubjects[index];
                return ListTile(
                  title: Text(subject.name),
                  subtitle: Text('Credits: ${subject.credits}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Credits: $_totalCredits',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

