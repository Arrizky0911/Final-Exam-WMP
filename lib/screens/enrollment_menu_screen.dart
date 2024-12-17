import 'package:flutter/material.dart';
import 'package:myapp/screens/subject_selection_screen.dart';
import 'package:myapp/screens/enrollment_summary_screen.dart';

class EnrollmentMenuScreen extends StatelessWidget {
  const EnrollmentMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enrollment Menu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SubjectSelectionScreen()),
                );
              },
              child: const Text('Select Subjects'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EnrollmentSummaryScreen()),
                );
              },
              child: const Text('View Enrollment Summary'),
            ),
          ],
        ),
      ),
    );
  }
}

