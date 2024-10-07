import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  final String userId;
  const SchedulePage({super.key, required this.userId});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  Future<Map<String, dynamic>?> _fetchUserDetails() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      List<Map<String, dynamic>> schedules = [];

      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

        String userName = userData?['name'] ?? 'Unknown User'; // Provide a fallback

        QuerySnapshot scheduleSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('schedules')
            .get();

        schedules = scheduleSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        return {
          'name': userName,
          'schedules': schedules,
        };
      } else {
        // Return null if user does not exist
        print('User does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }



  Future<String?> _fetchSubjectName(String subjectId) async {
    try {
      DocumentSnapshot subjectDoc = await FirebaseFirestore.instance.collection('subjects').doc(subjectId).get();
      if (subjectDoc.exists) {
        final data = subjectDoc.data() as Map<String, dynamic>;
        return data['name'] as String?;
      }
    } catch (e) {
      print('Error fetching subject name: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _fetchSchedulesWithSubjectNames() async {
    final userDetails = await _fetchUserDetails();
    if (userDetails == null) return [];

    final List<Map<String, dynamic>> schedules = userDetails['schedules'];
    List<Map<String, dynamic>> schedulesWithNames = [];

    List<Future<Map<String, dynamic>>> subjectFutures = [];

    for (var schedule in schedules) {
      subjectFutures.add(_fetchSubjectName(schedule['subject']).then((subjectName) {
        return {
          ...schedule,
          'subjectName': subjectName ?? 'Unknown', // Fallback to 'Unknown'
        };
      }));
    }

    // Wait for all subject fetch requests to complete
    schedulesWithNames = await Future.wait(subjectFutures);

    // Sort the schedules by day and check-in time
    schedulesWithNames.sort((a, b) {
      // Define the order of days
      const List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      int dayA = daysOfWeek.indexOf(a['day']);
      int dayB = daysOfWeek.indexOf(b['day']);

      // First, compare the day
      if (dayA != dayB) {
        return dayA.compareTo(dayB);
      } else {
        // If the same day, compare check-in times
        return a['checkInTime'].compareTo(b['checkInTime']);
      }
    });


    return schedulesWithNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSchedulesWithSubjectNames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error fetching user details'));
          }

          final schedules = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: schedules.isEmpty
                ? Center(child: Text('No schedules found.'))
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Allows horizontal scrolling if needed
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Day')),
                  DataColumn(label: Text('Time')),
                  DataColumn(label: Text('Subject')),
                  DataColumn(label: Text('Class')),
                ],
                rows: schedules.map<DataRow>((schedule) {
                  return DataRow(cells: [
                    DataCell(Text(schedule['day'] ?? '')),
                    DataCell(
                      Row(
                        children: [
                          Text(schedule['checkInTime'] ?? ''), // Display check-in time
                          Text(' - '), // Spacing between times
                          Text(schedule['checkOutTime'] ?? '') // Display check-out time
                        ],
                      ),
                    ),
                    DataCell(Text(schedule['subjectName'] ?? '')), // Fetched subject name
                    DataCell(Text(schedule['class'] ?? '')),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
