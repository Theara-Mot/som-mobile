import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:som_mobile/const/app_color.dart';
import 'package:som_mobile/screen/admin/user/user_attendance.dart';
import 'package:som_mobile/screen/admin/user/user_profile.dart';
import 'package:som_mobile/screen/admin/user/user_schedule.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  const UserDetailPage({super.key, required this.userId});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  Future<void> _markAbsentForPastDays() async {
    try {
      final today = DateTime.now();
      final attendanceSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('attendance')
          .get();

      final List<Map<String, dynamic>> attendanceRecords = attendanceSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      final scheduleSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('schedules')
          .get();

      final List<Map<String, dynamic>> schedules = scheduleSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      final Map<String, String> scheduleMap = {};
      for (var schedule in schedules) {
        scheduleMap[schedule['day']] = schedule['id']; // Assuming 'day' and 'id' exist
      }

      for (int i = 1; i <= 7; i++) {
        final pastDate = DateFormat('yyyy-MM-dd').format(today.subtract(Duration(days: i)));

        // Check if a record exists for the past date
        final recordExists = attendanceRecords.any((record) => record['date'] == pastDate);

        if (!recordExists) {
          final pastDay = DateFormat('EEEE').format(DateTime.parse(pastDate));

          final scheduleId = scheduleMap[pastDay] ?? '';

          if (scheduleId.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userId)
                .collection('attendance')
                .add({
              'date': pastDate,
              'status': 'Absent',
              'scheduleId': scheduleId,
            });
          }
        }
      }
    } catch (e) {
      print('Error marking absent for past days: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    _markAbsentForPastDays();
  }



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.blueColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white), // Back button icon
        onPressed: () {
          Navigator.pop(context); // Go back to the previous screen
        },
      ),
      title: Text(
        'User Detail',
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: false,
          bottom: TabBar(
            labelColor:Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Schedule'),
              Tab(text: 'Attendance'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            UserProfile(userID: widget.userId,),
            SchedulePage(userId: widget.userId),
            AttendancePage(userId: widget.userId),
          ],
        ),
      ),
    );
  }
}

