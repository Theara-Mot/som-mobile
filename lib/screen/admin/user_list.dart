import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:som_mobile/screen/admin/user_detail.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Method to fetch users from Firestore
  void _fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _users = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
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
        ),
      ),
    );
  }
}
