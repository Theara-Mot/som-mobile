import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  final String userId;
  const AttendancePage({super.key, required this.userId});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  Future<Map<String, dynamic>?> _fetchUserDetails() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      List<Map<String, dynamic>> schedules = [];
      if (userDoc.exists) {
        QuerySnapshot scheduleSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('schedules')
            .get();
        schedules = scheduleSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        // Sort schedules by day and time
        schedules.sort((a, b) {
          int dayComparison = _compareDays(a['day'], b['day']);
          if (dayComparison != 0) return dayComparison;
          return _compareCheckInTimes(a['checkInTime'], b['checkInTime']);
        });
      }
      return {
        'name': userDoc['name'],
        'schedules': schedules,
      };
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  int _compareDays(String? dayA, String? dayB) {
    const daysOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return daysOrder.indexOf(dayA ?? '') - daysOrder.indexOf(dayB ?? '');
  }

  int _compareCheckInTimes(String? timeA, String? timeB) {
    return _convertToMinutes(timeA!).compareTo(_convertToMinutes(timeB!));
  }

  int _convertToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    return 0;
  }

  DateTime _getScheduleDate(String scheduleDay, String currentDate) {
    final today = DateTime.parse(currentDate);
    final daysOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    int todayIndex = daysOrder.indexOf(DateFormat('EEEE').format(today));

    int scheduleIndex = daysOrder.indexOf(scheduleDay);
    DateTime scheduleDate;

    // If the scheduled day is today or in the future
    if (scheduleIndex >= todayIndex) {
      scheduleDate = today.add(Duration(days: scheduleIndex - todayIndex));
    } else {
      // If the scheduled day is in the next week
      scheduleDate = today.add(Duration(days: 7 - (todayIndex - scheduleIndex)));
    }

    return scheduleDate;
  }

  DateTime _convertToDateTime(String dateTimeStr) {
    final parts = dateTimeStr.split(' ');
    final datePart = parts[0]; // e.g., "2024-10-04"
    final timePart = parts[1]; // e.g., "7:00"

    final timeParts = timePart.split(':');
    String hour = timeParts[0].padLeft(2, '0');
    String minute = timeParts.length > 1 ? timeParts[1].padLeft(2, '0') : '00';

    final formattedDateTimeStr = '$datePart $hour:$minute:00';

    return DateTime.parse(formattedDateTimeStr);
  }

  Future<Map<String, dynamic>> _fetchAttendanceData() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('attendance')
          .where('date', isEqualTo: today)
          .get();

      List<Map<String, dynamic>> attendanceRecords = attendanceSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      return {'records': attendanceRecords};
    } catch (e) {
      print('Error fetching attendance data: $e');
      return {'records': []}; // Return an empty list in case of error
    }
  }
  Future<Map<String, String>> _fetchSubjectDetails(String subjectId) async {
    try {
      DocumentSnapshot subjectDoc = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectId)
          .get();

      if (subjectDoc.exists) {
        return {'subject': subjectDoc['name']}; // Assuming 'subject' is the field name in the subjects collection
      }
    } catch (e) {
      print('Error fetching subject details: $e');
    }
    return {'subject': 'Unknown'}; // Default return if there's an error
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error fetching user details'));
          }

          final userData = snapshot.data!;
          final schedules = userData['schedules'];

          return FutureBuilder<Map<String, dynamic>>(
            future: _fetchAttendanceData(),
            builder: (context, attendanceSnapshot) {
              if (attendanceSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (attendanceSnapshot.hasError || !attendanceSnapshot.hasData) {
                return Center(child: Text('Error fetching attendance data'));
              }

              final attendanceRecords = attendanceSnapshot.data!['records'];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: schedules.isEmpty
                    ? Center(child: Text('No schedules found.'))
                    : ListView.builder(
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    final scheduleId = schedule['id'];
                    final checkInTime = schedule['checkInTime']; // e.g., "7:00"
                    final checkOutTime = schedule['checkOutTime']; // e.g., "9:00"
                    final currentTime = DateTime.now();
                    final today = DateFormat('EEEE').format(currentTime);
                    final currentDate = DateFormat('yyyy-MM-dd').format(currentTime);

                    // Get the scheduled day
                    final scheduleDay = schedule['day'];
                    final scheduleDate = _getScheduleDate(scheduleDay, currentDate);

                    final scheduleStartTime = _convertToDateTime('$scheduleDate $checkInTime:00');
                    final scheduleEndTime = _convertToDateTime('$scheduleDate $checkOutTime:00');

                    // Check if there's attendance for today
                    final attendanceRecord = attendanceRecords.firstWhere(
                          (record) => record['scheduleId'] == scheduleId,
                      orElse: () => {'status': 'Absent'}, // Default return
                    );

                    String status;
                    if (scheduleDate.isAfter(currentTime)) {
                      // Current date is before the scheduled date
                      status = 'Coming';
                    } else if (scheduleDate.isAtSameMomentAs(currentTime) && scheduleStartTime.isAfter(currentTime)) {
                      // Current time is before scheduled check-in time today
                      status = 'Pending';
                    } else {
                      if (currentTime.isAfter(scheduleEndTime)) {
                        // Current time is after scheduled check-out time
                        if (attendanceRecord.isNotEmpty && attendanceRecord['status'] == 'Present') {
                          status = 'Present';
                        } else {
                          status = 'Absent';
                        }
                      } else {
                        // Current time is within the scheduled check-in and check-out time range
                        status = 'Pending';
                      }
                    }

                    // Fetch subject details
                    return FutureBuilder<Map<String, String>>(
                      future: _fetchSubjectDetails(schedule['subject']), // Assuming subjectId is stored here
                      builder: (context, subjectSnapshot) {
                        if (subjectSnapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(title: Text('Loading subject...'));
                        }
                        if (subjectSnapshot.hasError || !subjectSnapshot.hasData) {
                          return ListTile(title: Text('Error fetching subject'));
                        }

                        final subjectName = subjectSnapshot.data!['subject'];

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(8.0), // Add padding to the container
                          decoration: BoxDecoration(
                            color: Colors.white, // Set the background color
                            borderRadius: BorderRadius.circular(8.0), // Round the corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3), // Shadow color
                                spreadRadius: 1, // Spread radius of the shadow
                                blurRadius: 5, // Blur radius of the shadow
                                offset: const Offset(0, 2), // Position of the shadow
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to space between
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                                  children: [
                                    Text('${schedule['day']} | ${schedule['checkInTime']} - ${schedule['checkOutTime']}',
                                        style: TextStyle(fontFamily: 'Khmer') // Style for title
                                    ),
                                    Divider(),
                                    Text('${schedule['class']} | $subjectName',
                                        style: TextStyle(color: Colors.grey,fontFamily: 'Khmer') // Style for subtitle
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8), // Add spacing between text and trailing
                              Text(status,
                                  style: TextStyle(fontWeight: FontWeight.bold) // Style for trailing
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
