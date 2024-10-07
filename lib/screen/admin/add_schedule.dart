import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:som_mobile/service/class_service.dart';
import 'package:som_mobile/util/build_button.dart';

class AddSchedule extends StatefulWidget {
  @override
  _AddScheduleState createState() => _AddScheduleState();
}

class _AddScheduleState extends State<AddSchedule> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedUserId, _checkInTime, _checkOutTime, _day, _subject, _class;
  List<Map<String, dynamic>> _users = [];
  List<String> _userSubjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    var querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _users = querySnapshot.docs.map((doc) => {'id': doc.id, 'name': doc['name']}).toList();
      _isLoading = false;
    });
  }

  void _fetchUserSubjects(String userId) async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      _userSubjects = List<String>.from(userDoc['subjects'] ?? []);
    });
  }

  void _submitSchedule() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var scheduleData = {
        'checkInTime': _checkInTime,
        'checkOutTime': _checkOutTime,
        'day': _day,
        'subject': _subject, // Directly use the selected subject
        'class': _class,
      };
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_selectedUserId)
            .collection('schedules')
            .add(scheduleData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Schedule created successfully!')));
        _formKey.currentState!.reset();
        setState(() {
          _selectedUserId = null;
          _userSubjects = [];
          _day = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create schedule: $e')));
      }
    }
  }

  void _selectUser() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              _modalHeader('Select User'),
              Expanded(
                child: ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      title: Text(user['name']),
                      onTap: () {
                        setState(() {
                          _selectedUserId = user['id'];
                          _fetchUserSubjects(_selectedUserId!); // Fetch user subjects
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

  void _selectDay() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              _modalHeader('Select Day'),
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

  Widget _modalHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
          IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _isLoading ? CircularProgressIndicator() : _buildUserSelector(),
              if (_userSubjects.isNotEmpty) _buildSubjectSelector(),
              Row(
                children: [
                  Expanded(child: _buildTimeInput('Check In', (value) => _checkInTime = value)),
                  Expanded(child: _buildTimeInput('Check Out', (value) => _checkOutTime = value)),
                ],
              ),
              _buildDaySelector(),
              _buildTimeInput('Class', (value) => _class = value),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: BuildButton(onPressed: _submitSchedule, text: 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserSelector() {
    return GestureDetector(
      onTap: _selectUser,
      child: Card(
        color: Colors.white,
        child: ListTile(
          title: Text(_selectedUserId != null
              ? _users.firstWhere((user) => user['id'] == _selectedUserId)['name']
              : 'Tap to select a user'),
        ),
      ),
    );
  }
  NameService nameService = NameService('subjects');

  Widget _buildSubjectSelector() {
    return FutureBuilder<List<Widget>>(
      future: _fetchSubjectWidgets(),
      builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Handle error case
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No subjects available'); // Handle empty subjects case
        } else {
          return Column(children: snapshot.data!); // Display subject radio buttons
        }
      },
    );
  }

  Future<List<Widget>> _fetchSubjectWidgets() async {
    List<Widget> subjectWidgets = [];

    for (String subjectId in _userSubjects) {
      String? subjectName = await nameService.getNameById(subjectId);
      if (subjectName != null) {
        subjectWidgets.add(
          RadioListTile<String>(
            title: Text(subjectName),
            value: subjectId,
            groupValue: _subject,
            onChanged: (value) {
              setState(() {
                _subject = value;
              });
            },
          ),
        );
      }
    }
    return subjectWidgets;
  }


  Widget _buildDaySelector() {
    return GestureDetector(
      onTap: _selectDay,
      child: Card(
        color: Colors.white,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          title: Text(_day ?? 'Tap to select a day'),
        ),
      ),
    );
  }

  Widget _buildTimeInput(String hint, void Function(String?) onSaved) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
          ),
          validator: (value) => value?.isEmpty == true ? 'Please enter $hint' : null,
          onSaved: onSaved,
        ),
      ),
    );
  }
}
