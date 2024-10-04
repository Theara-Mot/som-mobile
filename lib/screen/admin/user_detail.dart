import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class UserDetailPage extends StatefulWidget {
  final String userId;
  const UserDetailPage({super.key, required this.userId});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
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
          return _compareTimes(a['time'], b['time']);
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

  int _compareDays(String? dayA, String? dayB) {
    const daysOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return daysOrder.indexOf(dayA ?? '') - daysOrder.indexOf(dayB ?? '');
  }

  int _compareTimes(String? timeA, String? timeB) {
    final isRangeA = timeA?.contains('-') ?? false;
    final isRangeB = timeB?.contains('-') ?? false;

    if (isRangeA && isRangeB) {
      final timeAParts = timeA!.split('-').map((t) => _convertToMinutes(t.trim())).toList();
      final timeBParts = timeB!.split('-').map((t) => _convertToMinutes(t.trim())).toList();

      int startComparison = timeAParts[0].compareTo(timeBParts[0]);
      return startComparison != 0 ? startComparison : timeAParts[1].compareTo(timeBParts[1]);
    } else if (!isRangeA && !isRangeB) {
      return _convertToMinutes(timeA!).compareTo(_convertToMinutes(timeB!));
    } else if (isRangeA) {
      final timeAParts = timeA!.split('-').map((t) => _convertToMinutes(t.trim())).toList();
      return timeAParts[0].compareTo(_convertToMinutes(timeB!));
    } else {
      final timeBParts = timeB!.split('-').map((t) => _convertToMinutes(t.trim())).toList();
      return _convertToMinutes(timeA!).compareTo(timeBParts[0]);
    }
  }

  int _convertToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } else if (parts.length == 1) {
      final hourParts = parts[0].split('-');
      if (hourParts.length == 2) {
        // Handle range
        return int.parse(hourParts[0].trim()) * 60; // Use start of the range
      }
      return int.parse(hourParts[0].trim()) * 60;
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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('User Details'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Schedule'),
              Tab(text: 'Attendance'),
            ],
          ),
        ),
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

            return TabBarView(
              children: [
                // Schedule View
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: schedules.isEmpty
                      ? Center(child: Text('No schedules found.'))
                      : DataTable(
                    columns: const [
                      DataColumn(label: Text('Day')),
                      DataColumn(label: Text('Time')),
                      DataColumn(label: Text('Subject')),
                      DataColumn(label: Text('Class')),
                    ],
                    rows: schedules.map<DataRow>((schedule) {
                      return DataRow(cells: [
                        DataCell(Text(schedule['day'] ?? '')),
                        DataCell(Text(schedule['time'] ?? '')),
                        DataCell(Text(schedule['subject'] ?? '')),
                        DataCell(Text(schedule['class'] ?? '')),
                      ]);
                    }).toList(),
                  ),
                ),

                // Attendance View
                FutureBuilder<Map<String, dynamic>>(
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
                            final scheduleTime = schedule['time']; // e.g., "7-9"
                            final currentTime = DateTime.now();
                            final today = DateFormat('EEEE').format(currentTime); // Get current day of the week
                            final currentDate = DateFormat('yyyy-MM-dd').format(currentTime);

                            // Handle schedule time parsing
                            final scheduleDay = schedule['day']; // Get the day from the schedule
                            final scheduleDate = _getScheduleDate(scheduleDay, currentDate); // Get the correct date for the schedule

                            final scheduleStartTime = _convertToDateTime('$scheduleDate ${scheduleTime.split('-').first.trim()}:00');

                            // Check if there's attendance for today
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
                              // Current time is before scheduled start time today
                              status = 'Pending';
                            } else {
                              // Parse the end time of the schedule
                              final scheduleEndTime = _convertToDateTime('$scheduleDate ${scheduleTime.split('-').last.trim()}:00');

                              if (currentTime.isAfter(scheduleEndTime)) {
                                // Current time is after scheduled end time
                                if (attendanceRecord.isNotEmpty && attendanceRecord['status'] == 'Present') {
                                  // Attendance marked as present
                                  status = 'Present';
                                } else {
                                  // Attendance not marked
                                  status = 'Absent';
                                }
                              } else {
                                // Current time is within the scheduled time range
                                status = 'Pending';
                              }
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
                          }

                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  DateTime _convertToDateTime(String dateTimeStr) {
    // Split date and time
    final parts = dateTimeStr.split(' ');
    final datePart = parts[0]; // e.g., "2024-10-04"
    final timePart = parts[1]; // e.g., "7:00"

    // Ensure the time is in 24-hour format
    final timeParts = timePart.split(':');
    String hour = timeParts[0].padLeft(2, '0'); // Ensure two-digit hour
    String minute = timeParts.length > 1 ? timeParts[1].padLeft(2, '0') : '00'; // Ensure two-digit minute

    // Construct the new formatted string
    final formattedDateTimeStr = '$datePart $hour:$minute:00';

    // Parse the formatted date time string
    return DateTime.parse(formattedDateTimeStr);
  }

}

