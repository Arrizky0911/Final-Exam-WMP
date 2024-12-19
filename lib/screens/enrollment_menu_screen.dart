import 'package:flutter/material.dart';
import 'package:myapp/screens/subject_selection_screen.dart';
import 'package:myapp/screens/enrollment_summary_screen.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentMenuScreen extends StatefulWidget {
  const EnrollmentMenuScreen({super.key});

  @override
  State<EnrollmentMenuScreen> createState() => _EnrollmentMenuScreenState();
}

class _EnrollmentMenuScreenState extends State<EnrollmentMenuScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userName = '';
  String _userEmail = '';
  AppBar? appBar;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('students').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _userName = data['name'] ?? 'Student';
            _userEmail = user.email ?? '';
            String? profilePicUrl = data['profilePicUrl'];
            if (profilePicUrl != null && profilePicUrl.isNotEmpty) {
              _updateAppBarWithProfilePic(profilePicUrl);
            }
          });
        }
      } catch (e) {
        print('Error loading user info: $e');
      }
    }
  }

  void _updateAppBarWithProfilePic(String url) {
    setState(() {
      appBar = AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, AppTheme.accentColor],
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(url),
            ),
            SizedBox(width: 12),
            Text(_userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _signOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      );
    });
  }

  void _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, AppTheme.accentColor],
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: _userName.isNotEmpty
                  ? Text(_userName[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))
                  : const Icon(Icons.person, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _signOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome, $_userName!',
                style: AppTheme.headingStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _userEmail,
                style: AppTheme.subheadingStyle.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildMenuCard(
                      context,
                      'Select Subjects',
                      Icons.book,
                      AppTheme.primaryColor,
                          () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SubjectSelectionScreen()),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'View Enrollment Summary',
                      Icons.summarize,
                      AppTheme.accentColor,
                          () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => EnrollmentSummaryScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.7), color],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  title,
                  style: AppTheme.subheadingStyle.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

