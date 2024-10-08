import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:som_mobile/const/app_color.dart';
import 'package:som_mobile/screen/admin/add_schedule.dart';
import 'admin/user/user_detail.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        appBar: AppBar(
          backgroundColor: AppColor.blueColor,
          title: const Text('Admin Page',style: TextStyle(color: Colors.white),),
          bottom: const TabBar(
            labelColor:Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'User List'),
              Tab(text: 'Create Schedule'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            UserListTab(), // Tab for user list
            CreateScheduleTab(), // Tab for creating schedules
          ],
        ),
      ),
    );
  }
}

class UserListTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error fetching users'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return GestureDetector(
  onTap: () {
    // Navigate to UserDetailPage when a user is tapped
    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                          return UserDetailPage(userId: user['id']);
                        }),
                      );
    
  },
  child: Container(
    padding: EdgeInsets.all(8.0),
    margin: EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
          user['name'],
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          user['level'],
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: Colors.grey
          ),
        ),
          ],
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16.0,
        ),
      ],
    ),
  ),
);

            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'level':doc['level']
        };
      }).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
}

class CreateScheduleTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AddSchedule(); // Your existing CreateSchedulePage
  }
}
