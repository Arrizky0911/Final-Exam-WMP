import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/subject.dart';
import 'package:myapp/theme/app_theme.dart';

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
    try {
      final userId = _auth.currentUser!.uid;
      final studentDoc = await _firestore.collection('students').doc(userId).get();

      if (studentDoc.exists) {
        final data = studentDoc.data() as Map<String, dynamic>;
        final subjectIds = List<String>.from(data['subjects'] ?? []);

        if (subjectIds.isNotEmpty) {
          final subjectsSnapshot = await _firestore
              .collection('subjects')
              .where(FieldPath.documentId, whereIn: subjectIds)
              .get();

          setState(() {
            _enrolledSubjects = subjectsSnapshot.docs
                .map((doc) => Subject.fromFirestore(doc))
                .toList();
            _totalCredits = data['totalCredits'] ?? 0;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading enrolled subjects: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading enrolled subjects. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Your Enrolled Subjects',
              style: AppTheme.headingStyle,
            ),
          ),
          Expanded(
            child: _enrolledSubjects.isEmpty
                ? const Center(child: Text('No subjects enrolled yet.', style: AppTheme.bodyStyle))
                : ListView.builder(
              itemCount: _enrolledSubjects.length,
              itemBuilder: (context, index) {
                final subject = _enrolledSubjects[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(subject.name, style: AppTheme.bodyStyle),
                    subtitle: Text('${subject.code} - ${subject.credits} credits'),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.accentColor,
                      child: Text(
                        subject.name.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Credits:',
                  style: AppTheme.subheadingStyle,
                ),
                Text(
                  '$_totalCredits',
                  style: AppTheme.headingStyle.copyWith(color: AppTheme.accentColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

