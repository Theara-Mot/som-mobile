import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:som_mobile/const/app_color.dart';
import 'package:som_mobile/model/class_model.dart';
import 'package:som_mobile/util/build_backappbar.dart';
import 'package:som_mobile/util/build_button.dart';
import '../../model/user_model.dart';
import '../../service/class_service.dart';
import '../../service/user_service.dart';
import '../../util/build_textfield.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService _userService = UserService('users');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roleIdController = TextEditingController();
  final TextEditingController _departmentIdController = TextEditingController();
  final TextEditingController _subjectsController = TextEditingController();
  final NameService _departmentService = NameService('departments');
  final NameService _roleService = NameService('roles');
  final NameService _subjectService = NameService('subjects');
  String? _selectedUserId;
  String? _selectedRole;
  String? _selectedDepartment;
  bool _isVisible = false;
  String pickedDate = '';
  List<Map<String,dynamic>> _selectedSubjects = []; // Change to List<String>

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: BuildBackAppbar(
        title: 'Users',
        onActionPressed: () {
          setState(() {
            _isVisible = !_isVisible;
            if (!_isVisible) {
              _clearInputFields();
            }
          });
        },
        actionIcon: !_isVisible ? Icons.add : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (_isVisible) ...[
              buildTextField(
                labelText: 'Name',
                controller: _nameController,
              ),
              GestureDetector(
                onTap: () => _selectDate(),
                child: AbsorbPointer(
                  child: buildTextField(
                    labelText: 'Date of Birth',
                    controller: _dobController..text = _dobController.text.isEmpty ? 'Select Date' : _dobController.text,
                  ),
                ),
              ),
              buildTextField(
                labelText: 'Gender',
                controller: _genderController,
              ),
              buildTextField(
                labelText: 'Phone',
                controller: _phoneController,
              ),
              GestureDetector(
                onTap: () => _selectRole(),
                child: AbsorbPointer(
                  child: buildTextField(
                    labelText: 'Role',
                    controller: _roleIdController..text = _selectedRole ?? 'Select Role',
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectDepartment(),
                child: AbsorbPointer(
                  child: buildTextField(
                    labelText: 'Department',
                    controller: _departmentIdController..text = _selectedDepartment ?? 'Select Department',
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectSubject(),
                child: AbsorbPointer(
                  child: buildTextField(
                    labelText: 'Subjects',
                    controller: _subjectsController..text = _selectedSubjects.isEmpty
                        ? 'Select Subjects'
                        : _selectedSubjects.map((subject) => subject['name']).join(', '),
                  ),
                ),
              ),
              BuildButton(
                text: _selectedUserId == null ? 'Add User' : 'Update User',
                onPressed: () async {
                  // Extract the IDs from _selectedSubjects if it's a list of maps
                  final List<String> subjectIds = _selectedSubjects.map((subject) => subject['id'] as String).toList();

                  final user = UserModel(
                    id: _selectedUserId ?? '',
                    name: _nameController.text,
                    dob: DateTime.parse(_dobController.text),
                    gender: _genderController.text,
                    phone: _phoneController.text,
                    roleId: _roleIdController.text,
                    departmentId: _departmentIdController.text,
                    subjects: subjectIds,
                    joinDate: DateTime.now(), levelId: '',
                  );

                  if (_selectedUserId == null) {
                    await _userService.addUser(user);
                  } else {
                    await _userService.updateUser(user);
                    _selectedUserId = null; // Reset after updating
                  }

                  // _clearInputFields();
                  // _isVisible = false; // This variable likely controls the visibility of some UI element
                  setState(() {});
                },
              )
            ],

            StreamBuilder<List<UserModel>>(
              stream: _userService.getUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data ?? [];

                return Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return GestureDetector(
                        onTap: () {
                          _isVisible = true;
                          _nameController.text = user.name;
                          _dobController.text = user.dob.toIso8601String().split('T')[0]; // Format as YYYY-MM-DD
                          _genderController.text = user.gender;
                          _phoneController.text = user.phone;
                          _roleIdController.text = user.roleId;
                          _departmentIdController.text = user.departmentId;
                          _selectedSubjects[index]['id'] = user.subjects;
                          _subjectsController.text = user.subjects.join(', '); // Show subjects
                          _selectedUserId = user.id;
                          setState(() {});
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${user.name}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  await _userService.deleteUser(user.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    // _updateSubjectsController();
  }
  void _updateSubjectsController() {
    if (_selectedSubjects.isEmpty) {
      _subjectsController.text = 'Select Subjects';
    } else {
      // Join the names of the selected subjects
      _subjectsController.text = _selectedSubjects
          .map((subject) => subject['name'] as String)
          .join(', ');
    }
  }



  void _clearInputFields() {
    _nameController.clear();
    _dobController.clear();
    _genderController.clear();
    _phoneController.clear();
    _roleIdController.clear();
    _departmentIdController.clear();
    _subjectsController.clear();
    _selectedRole = null;
    _selectedDepartment = null;
    _selectedSubjects.clear(); // Clear the list of selected subjects
  }

  void _selectDate() async {
    DateTime currentDate = DateTime.now();

    DateTime? pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime tempDate = currentDate; // Initialize with current date
        return Container(
          height: 300,
          child: Column(
            children: [
              _modalHeader('Select Date'),
              Expanded(
                child: Container(
                  child: CupertinoDatePicker(
                    initialDateTime: currentDate,
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (DateTime newDate) {
                      tempDate = newDate;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: BuildButton(
                  text: 'Select',
                  onPressed: () {
                    Navigator.pop(context, tempDate);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    // Check if pickedDate is not null and update the state
    if (pickedDate != null) {
      setState(() {
        _dobController.text = pickedDate.toIso8601String().split('T')[0]; // Format as YYYY-MM-DD
      });
    }
  }

  void _selectRole() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              _modalHeader('Select Role'),
              Expanded(
                child: StreamBuilder<List<CDModel>>(
                  stream: _roleService.getNames(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final roles = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: roles.length,
                      itemBuilder: (context, index) {
                        final role = roles[index];
                        return ListTile(
                          title: Text(role.name),
                          onTap: () {
                            setState(() {
                              _selectedRole = role.name;
                              _roleIdController.text = role.id;
                            });
                            Navigator.pop(context);
                          },
                        );
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

  void _selectDepartment() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              _modalHeader('Select Department'),
              Expanded(
                child: StreamBuilder<List<CDModel>>(
                  stream: _departmentService.getNames(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final departments = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: departments.length,
                      itemBuilder: (context, index) {
                        final department = departments[index];
                        return ListTile(
                          title: Text(department.name),
                          onTap: () {
                            setState(() {
                              _selectedDepartment = department.name; // Store the selected department ID
                              _departmentIdController.text = department.id; // Display the department name
                            });
                            Navigator.pop(context);
                          },
                        );
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

  void _selectSubject() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          child: Column(
            children: [
              _modalHeader('Select Subjects'),
              Expanded(
                child: StreamBuilder<List<CDModel>>(
                  stream: _subjectService.getNames(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final subjects = snapshot.data ?? [];

                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return ListView.builder(
                          itemCount: subjects.length,
                          itemBuilder: (context, index) {
                            final subject = subjects[index];
                            final isSelected = _selectedSubjects
                                .any((s) => s['id'] == subject.id);
                            return ListTile(
                              title: Text(subject.name),
                              trailing: isSelected
                                  ? Icon(Icons.check, color: AppColor.primaryColor)
                                  : null,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    // Remove the subject if already selected
                                    _selectedSubjects.removeWhere((s) => s['id'] == subject.id);
                                  } else {
                                    // Add the subject if not selected
                                    _selectedSubjects.add({'id': subject.id, 'name': subject.name});
                                  }
                                  _updateSubjectsController(); // Update the text field
                                });
                              },
                            );
                          },
                        );
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

  Widget _modalHeader(String title) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
