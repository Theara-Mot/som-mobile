// schedule_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class SchedulePage extends StatelessWidget {
  final String userId;
  final List<Map<String, dynamic>> schedules;

  const SchedulePage({Key? key, required this.userId, required this.schedules}) : super(key: key);

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

  DateTime _getScheduleDate(String scheduleDay, String currentDate) {
    final today = DateTime.parse(currentDate);
    final daysOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    int todayIndex = daysOrder.indexOf(DateFormat('EEEE').format(today));
    int scheduleIndex = daysOrder.indexOf(scheduleDay);

    return scheduleIndex >= todayIndex
        ? today.add(Duration(days: scheduleIndex - todayIndex))
        : today.add(Duration(days: 7 - (todayIndex - scheduleIndex)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: schedules.isEmpty
          ? Center(child: Text('No schedules found.'))
          : FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAttendanceData(),
        builder: (context, attendanceSnapshot) {
          if (attendanceSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final attendanceRecords = attendanceSnapshot.data ?? [];

          return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              final scheduleId = schedule['id'];
              final currentTime = DateTime.now();
              final today = DateFormat('EEEE').format(currentTime);
              final currentDate = DateFormat('yyyy-MM-dd').format(currentTime);
              final scheduleDay = schedule['day'];
              final scheduleDate = _getScheduleDate(scheduleDay, currentDate);
              final scheduleTimeParts = schedule['time'].split('-');
              final scheduleStartTime = DateTime.parse('${scheduleDate.toIso8601String().split('T')[0]} ${scheduleTimeParts.first.trim()}:00');

              String status = 'Pending'; // Default status
              if (scheduleDate.isAfter(currentTime)) {
                status = 'Coming';
              } else if (currentTime.isAfter(scheduleStartTime)) {
                final attendanceRecord = attendanceRecords.firstWhere(
                      (record) => record['scheduleId'] == scheduleId,
                  orElse: () => {'status': 'Absent'},
                );
                status = attendanceRecord['status'] ?? 'Absent';
              }

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text('${schedule['day']} - ${schedule['time']}'),
                  subtitle: Text('Subject: ${schedule['subject']}, Class: ${schedule['class']}'),
                  trailing: Text(status),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}