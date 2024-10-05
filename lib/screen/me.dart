import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:som_mobile/util/build_appbar.dart';

class UserDataScreen extends StatelessWidget {
  const UserDataScreen({Key? key}) : super(key: key);

  // Function to calculate duration in years, months, and days
  Map<String, int> calculateDuration(DateTime joinDate) {
    DateTime now = DateTime.now();
    int years = now.year - joinDate.year;
    int months = now.month - joinDate.month;
    int days = now.day - joinDate.day;

    // Adjust months and years if necessary
    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month, 0).day; // Get the last day of the previous month
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    return {'years': years, 'months': months, 'days': days};
  }

  // Method to build a ListTile
  Widget buildTile(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 24), // Adjust the size as needed
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar:BuildAppbar(title: 'Profile'),
        body: Center(child: Text('No user is signed in.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar:BuildAppbar(title: 'Profile'),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          DateTime joinDate = (data['joinDate'] as Timestamp).toDate();
          Map<String, int> duration = calculateDuration(joinDate);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTile(Icons.person, 'Name: ${data['name']}'),
                  buildTile(Icons.transgender, 'Gender: ${data['gender']}'),
                  buildTile(Icons.cake, 'Date of Birth: ${DateFormat('yyyy-MM-dd').format(data['dob'].toDate())}'),
                  buildTile(Icons.phone, 'Phone: ${data['phone']}'),
                  buildTile(Icons.grade, 'Level: ${data['level']}'),
                  buildTile(Icons.subject, 'Main Subject: ${data['mainSubject']}'),
                  buildTile(Icons.date_range, 'Join Date: ${DateFormat('yyyy-MM-dd').format(joinDate)}'),
                  buildTile(Icons.access_time, 'Duration Worked: ${duration['years']} years, ${duration['months']} months, ${duration['days']} days'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}