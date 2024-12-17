import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/subject.dart';

class SubjectSelectionScreen extends StatefulWidget {
  @override
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<Subject> _subjects = [];
  final Set<String> _selectedSubjects = {};
  int _totalCredits = 0;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final querySnapshot = await _firestore.collection('subjects').get();
    setState(() {
      _subjects =
          querySnapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList();
    });
  }

  Future<void> _enrollSubjects() async {
    final userId = _auth.currentUser!.uid;
    final batch = _firestore.batch();
    for (String subjectId in _selectedSubjects) {
      final enrollmentRef = _firestore.collection('enrollments').doc();
      batch.set(enrollmentRef, {
        'student_id': userId,
        'subject_id': subjectId,
      });
    }
    await batch.commit();
    Navigator.of(context).pop(); // Go back to enrollment menu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Subjects')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                return CheckboxListTile(
                  title: Text(subject.name),
                  subtitle: Text('Credits: ${subject.credits}'),
                  value: _selectedSubjects.contains(subject.id),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        if (_totalCredits + subject.credits <= 24) {
                          _selectedSubjects.add(subject.id);
                          _totalCredits += subject.credits;
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Maximum credits (24) exceeded')),
                          );
                        }
                      } else {
                        _selectedSubjects.remove(subject.id);
                        _totalCredits -= subject.credits;
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Total Credits: $_totalCredits',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _enrollSubjects,
                  child: const Text('Enroll'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
