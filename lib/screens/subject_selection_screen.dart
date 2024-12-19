import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/subject.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/screens/enrollment_summary_screen.dart';

class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Subject> _subjects = [];
  Set<String> _selectedSubjects = {};
  int _totalCredits = 0;
  bool _isEnrolled = false;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    _checkEnrollmentStatus();
  }

  Future<void> _loadSubjects() async {
    try {
      final querySnapshot = await _firestore.collection('subjects').get();
      setState(() {
        _subjects = querySnapshot.docs
            .map((doc) => Subject.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading subjects: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading subjects. Please try again.')),
      );
    }
  }

  Future<void> _checkEnrollmentStatus() async {
    try {
      final userId = _auth.currentUser!.uid;
      final studentDoc = await _firestore.collection('students').doc(userId).get();
      if (studentDoc.exists) {
        final data = studentDoc.data() as Map<String, dynamic>;
        setState(() {
          _isEnrolled = data['enrolled'] ?? false;
          if (_isEnrolled) {
            _selectedSubjects = Set<String>.from(data['subjects'] ?? []);
            _totalCredits = data['totalCredits'] ?? 0;
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking enrollment status: $e');
      }
    }
  }

  Future<void> _enrollSubjects() async {
    try {
      final userId = _auth.currentUser!.uid;
      await _firestore.collection('students').doc(userId).set({
        'subjects': _selectedSubjects.toList(),
        'totalCredits': _totalCredits,
        'enrolled': true,
      }, SetOptions(merge: true));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => EnrollmentSummaryScreen()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error enrolling subjects: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error enrolling subjects. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Subjects'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isEnrolled
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You are already enrolled.',
              style: AppTheme.headingStyle,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => EnrollmentSummaryScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View Enrollment Summary'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select your subjects (max 24 credits)',
              style: AppTheme.subheadingStyle,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                final isSelected = _selectedSubjects.contains(subject.id);
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
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(isSelected ? 'Remove' : 'Select'),
                      onPressed: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSubjects.remove(subject.id);
                            _totalCredits -= subject.credits;
                          } else {
                            if (_totalCredits + subject.credits <= 24) {
                              _selectedSubjects.add(subject.id);
                              _totalCredits += subject.credits;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Maximum credits (24) exceeded')),
                              );
                            }
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total Credits: $_totalCredits',
                  style: AppTheme.subheadingStyle,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedSubjects.isNotEmpty ? _enrollSubjects : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Enroll'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
