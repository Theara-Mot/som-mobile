// attendance_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatelessWidget {
  final String userId;

  const AttendancePage({Key? key, required this.userId}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchAttendanceData() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .where('date', isEqualTo: today)
          .get();

      return attendanceSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching attendance data: $e');
      return []; // Return an empty list in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchAttendanceData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final attendanceRecords = snapshot.data ?? [];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: attendanceRecords.isEmpty
              ? Center(child: Text('No attendance records found.'))
              : ListView.builder(
            itemCount: attendanceRecords.length,
            itemBuilder: (context, index) {
              final record = attendanceRecords[index];
              return ListTile(
                title: Text('Date: ${record['date']}'),
                subtitle: Text('Status: ${record['status']}'),
              );
            },
          ),
        );
      },
    );
  }
}