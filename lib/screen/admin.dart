import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:som_mobile/screen/admin/add_schedule.dart';

import 'admin/user_detail.dart';
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
        appBar: AppBar(
          title: const Text('Admin Page'),
          bottom: const TabBar(
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
              return ListTile(
                title: Text(user['name']),
                onTap: () {
                  // Navigate to UserDetailPage when a user is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailPage(userId: user['id']),
                    ),
                  );
                },
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
