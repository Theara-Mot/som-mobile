import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSchedule extends StatefulWidget {
  @override
  _AddScheduleState createState() => _AddScheduleState();
}

class _AddScheduleState extends State<AddSchedule> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedUserId; // For storing the selected user ID
  String? _time;
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
        'time': _time,
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

  // Method to show the day selection bottom sheet
  void _selectDay() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              ListTile(
                title: Text('Select Day'),
                trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: ListView(
                  children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map((day) {
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
      appBar: AppBar(title: const Text('Admin Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Dropdown for selecting a user
              _isLoading
                  ? CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                value: _selectedUserId,
                decoration: InputDecoration(labelText: 'Select User'),
                items: _users.map((user) {
                  return DropdownMenuItem<String>(
                    value: user['id'],
                    child: Text(user['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUserId = value;
                    _fetchUserSubjects(value!); // Fetch subjects for the selected user
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a user';
                  }
                  return null;
                },
              ),
              // Display subjects as radio buttons if there are 1 or 2
              if (_userSubjects.length > 0 && _userSubjects.length <= 2) ...[
                Text('Select Subject:'),
                ..._userSubjects.map((subject) {
                  return RadioListTile<String>(
                    title: Text(subject),
                    value: subject,
                    groupValue: _subject,
                    onChanged: (value) {
                      setState(() {
                        _subject = value;
                      });
                    },
                  );
                }).toList(),
              ],
              // If more than 2 subjects, use a regular TextFormField
              if (_userSubjects.length > 2) ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Subject (comma separated)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a subject';
                    }
                    return null;
                  },
                  onSaved: (value) => _subject = value,
                ),
              ],
              TextFormField(
                decoration: InputDecoration(labelText: 'Time'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a time';
                  }
                  return null;
                },
                onSaved: (value) => _time = value,
              ),
              // Button to select day
              GestureDetector(
                onTap: _selectDay,
                child: InputDecorator(
                  decoration: InputDecoration(labelText: 'Select Day'),
                  child: Text(_day ?? 'Tap to select a day', style: TextStyle(color: _day == null ? Colors.grey : Colors.black)),
                ),
              ),

              TextFormField(
                decoration: InputDecoration(labelText: 'Class'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a class';
                  }
                  return null;
                },
                onSaved: (value) => _class = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitSchedule,
                child: Text('Create Schedule'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}