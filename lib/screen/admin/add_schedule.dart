import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:som_mobile/util/build_button.dart';

class AddSchedule extends StatefulWidget {
  @override
  _AddScheduleState createState() => _AddScheduleState();
}

class _AddScheduleState extends State<AddSchedule> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedUserId; // For storing the selected user ID
  String? _checkInTime; // Check-in time
  String? _checkOutTime; // Check-out time
  String? _day; // Selected day
  String? _subject;
  String? _class;

  List<Map<String, dynamic>> _users = [];
  List<String> _userSubjects = [];
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

  // Method to fetch subjects for the selected user
  void _fetchUserSubjects(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        _userSubjects = List<String>.from(userDoc['mainSubject'] ?? []); // Assuming 'mainSubject' is an array field
      });
    } catch (e) {
      print('Error fetching subjects: $e');
    }
  }

  // Method to submit the schedule
  void _submitSchedule() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Prepare data to be saved
      Map<String, dynamic> scheduleData = {
        'checkInTime': _checkInTime, // Save check-in time
        'checkOutTime': _checkOutTime, // Save check-out time
        'day': _day,
        'subject': _subject?[0],
        'class': _class,
      };
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_selectedUserId) // Save under the selected user ID
            .collection('schedules') // Sub-collection for schedules
            .add(scheduleData); // Add the schedule data

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Schedule created successfully!')),
        );

        // Clear the form
        _formKey.currentState!.reset();
        setState(() {
          _selectedUserId = null; // Reset the selected user
          _userSubjects = []; // Clear subjects
          _day = null; // Clear selected day
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create schedule: $e')),
        );
      }
    }
  }

  void _selectDay() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),  
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8)
          ),
          height: 250,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Day',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'].map((day) {
                    return ListTile(
                      title: Text(day),
                      onTap: () {
                        setState(() {
                          _day = day;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _isLoading
                  ? CircularProgressIndicator()
                  : GestureDetector(
                      onTap: _selectUser, // Trigger user selection modal
                      child: Card(
                        color: Colors.white, // Set card color to white
                        elevation: 0, // Remove card outline
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              hintText: _selectedUserId != null
                                  ? _users.firstWhere((user) => user['id'] == _selectedUserId)['name']
                                  : 'Select User', // Show selected user's name or hint text
                              border: InputBorder.none, // Remove input border inside card
                            ),
                            child: Text(
                              _selectedUserId != null
                                  ? _users.firstWhere((user) => user['id'] == _selectedUserId)['name']
                                  : 'Tap to select a user',
                              style: TextStyle(
                                color: _selectedUserId == null ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
              if (_userSubjects.length > 0 && _userSubjects.length <= 2) ...[
                Text('Select Subject:'),
                ..._userSubjects.map((subject) {
                  return Card(
                    color: Colors.white,
                    elevation: 0, // Remove card outline
                    child: RadioListTile<String>(
                      title: Text(subject),
                      value: subject,
                      groupValue: _subject,
                      onChanged: (value) {
                        setState(() {
                          _subject = value;
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
              if (_userSubjects.length > 2) ...[
                Card(
                  color: Colors.white,
                  elevation: 0, // Remove card outline
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Subject (comma separated)', // Changed labelText to hintText
                      border: InputBorder.none, // Remove input border inside card
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a subject';
                      }
                      return null;
                    },
                    onSaved: (value) => _subject = value,
                  ),
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Check In', // Changed labelText to hintText
                            border: InputBorder.none, // Remove input border inside card
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter check-in time';
                            }
                            return null;
                          },
                          onSaved: (value) => _checkInTime = value,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Check Out',
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter check-out time';
                            }
                            return null;
                          },
                          onSaved: (value) => _checkOutTime = value,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _selectDay,
                child: Card(
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        hintText: 'Select Day', // Changed labelText to hintText
                        border: InputBorder.none, // Remove input border inside card
                      ),
                      child: Text(
                        _day ?? 'Tap to select a day',
                        style: TextStyle(
                          color: _day == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                elevation: 0, // Remove card outline
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Class', // Changed labelText to hintText
                    border: InputBorder.none, // Remove input border inside card
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter class';
                    }
                    return null;
                  },
                  onSaved: (value) => _class = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: BuildButton(
                  onPressed: _submitSchedule,
                  text: 'Save',
                
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectUser() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          height: 250,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select User',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (BuildContext context, int index) {
                    final user = _users[index];
                    return ListTile(
                      title: Text(user['name']),
                      onTap: () {
                        setState(() {
                          _selectedUserId = user['id']; // Save the selected user ID
                          _fetchUserSubjects(_selectedUserId!); // Fetch subjects for selected user
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
