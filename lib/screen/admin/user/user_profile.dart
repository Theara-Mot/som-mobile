import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:som_mobile/screen/auth/login.dart';
import 'package:som_mobile/util/build_appbar.dart';
import 'package:som_mobile/util/build_button.dart';

import '../../../model/user_model.dart';
import '../../../service/class_service.dart';

class UserProfile extends StatefulWidget {
  final String userID;
  UserProfile({Key? key, required this.userID}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  NameService nameService = NameService('subjects');
  List<String> names = [];
  String levelName = '';
  String departmentName = '';
  String roleName = "";


  // Function to calculate duration in years, months, and days
  Map<String, int> calculateDuration(DateTime joinDate) {
    DateTime now = DateTime.now();
    int years = now.year - joinDate.year;
    int months = now.month - joinDate.month;
    int days = now.day - joinDate.day;

    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    return {'years': years, 'months': months, 'days': days};
  }

  // Method to build a ListTile
  Widget buildTile(IconData icon, String title, {bool showTick = false}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: showTick ? Colors.green : null),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: TextStyle(fontFamily: 'Khmer')),
          ),
          if (showTick) Icon(Icons.check_circle_sharp, size: 24, color: Colors.green),
        ],
      ),
    );
  }

  Future<List<String>> getNamesByIds(List<String> ids) async {
    List<String> names = []; // Local list to store names
    for (String id in ids) {
      String? name = await nameService.getNameById(id);
      if (name != null) {
        names.add(name);
      }
    }
    return names;
  }

  // Update this method to return a Future<String?>
  Future<String?> getNameById(String id) async {
    return await nameService.getNameById(id);
  }
  @override
  void initState() {
    super.initState();
    _loadNames(); // Load names in initState
  }

  Future<void> _loadNames() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      UserModel currentUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>, user.uid);
      // Fetch names and update state
      levelName = await fetchName('levels', currentUser.levelId);
      departmentName = await fetchName('departments', currentUser.departmentId);
      roleName = await fetchName('roles', currentUser.roleId);

      setState(() {
        // This will trigger a rebuild
      });
    }
  }

  Future<String> fetchName(String col, String id) async {
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection(col).doc(id).get();
      return userDoc.exists ? userDoc['name'] : 'Unknown';
    } catch (e) {
      return 'Error fetching user $col';
    }
  }
  Stream<DocumentSnapshot> getUserStream() {
    return FirebaseFirestore.instance.collection('users').doc(widget.userID).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: StreamBuilder<DocumentSnapshot>(
        stream: getUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          UserModel currentUser = UserModel.fromMap(data, widget.userID);
          DateTime joinDate = currentUser.joinDate;
          Map<String, int> duration = calculateDuration(joinDate);

          // Fetch names if they are empty
          if (names.isEmpty) {
            getNamesByIds(currentUser.subjects).then((loadedNames) {
              setState(() {
                names = loadedNames;
              });
            });
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.lightBlueAccent.withOpacity(0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('personal_information'),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Khmer')),
                        const Divider(),
                        buildTile(Icons.person, '${tr('name')}: ${currentUser.name}'),
                        buildTile(Icons.transgender, '${tr('gender')}: ${currentUser.gender}'),
                        buildTile(Icons.cake, '${tr('dob')}: ${DateFormat('yyyy-MM-dd').format(currentUser.dob)}'),
                        buildTile(Icons.phone, '${tr('phone')}: ${currentUser.phone}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.lightBlueAccent.withOpacity(0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('additional_information'),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Khmer')),
                        const Divider(),
                        buildTile(Icons.grade, '${tr('level')}: ${levelName.isNotEmpty ? levelName : 'Loading...'}'),
                        buildTile(Icons.subject, '${tr('main_subject')}: ${names.isNotEmpty ? names.join(', ') : 'Loading...'}'),
                        buildTile(Icons.grade, '${tr('department')}: ${departmentName.isNotEmpty ? departmentName : 'Loading...'}'),
                        buildTile(Icons.grade, '${tr('role')}: ${roleName.isNotEmpty ? roleName : 'Loading...'}'),
                        buildTile(Icons.date_range, '${tr('join_date')}: ${DateFormat('yyyy-MM-dd').format(joinDate)}'),
                        buildTile(Icons.access_time,
                            '${tr('duration_worked')}: ${duration['years']} years, ${duration['months']} months, ${duration['days']} days'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
