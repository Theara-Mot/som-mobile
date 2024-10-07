import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class Signup extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<Signup> {
  final UserService _userService = UserService('users');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roleIdController = TextEditingController();
  final TextEditingController _LevelIdController = TextEditingController();
  final TextEditingController _departmentIdController = TextEditingController();
  final TextEditingController _subjectsController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Email controller
  final NameService _departmentService = NameService('departments');
  final NameService _roleService = NameService('roles');
  final NameService _subjectService = NameService('subjects');
  final NameService _levelService = NameService('levels');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedRole;
  String? _selectRoleId;
  String? _selectedDepartment;
  String? _selectedDepartmentId;
  String? _selectedLevel;
  String? _selectedLevelId;
  bool _isVisible = false;
  String pickedDate = '';
  List<Map<String,dynamic>> _selectedSubjects = [];
  Timer? _emailTimer;
  bool _isLoading = false;
  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _phoneController.text.trim() ?? '123456'; // Use trimmed password
    final List<String> subjectIds = _selectedSubjects.map((subject) => subject['id'] as String).toList();

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      // Sign up with Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;

        final user = UserModel(
          id: userId,
          name: _nameController.text,
          dob: DateTime.parse(_dobController.text),
          gender: _genderController.text,
          phone: _phoneController.text,
          roleId: _selectRoleId??'',
          departmentId: _selectedDepartmentId??'',
          subjects: subjectIds,
          joinDate: DateTime.now(),
          levelId: _selectedLevelId??'',
        );

        await _userService.addUser(user);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup successful!')),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      // Handle signup errors
      print('Signup failed: $e');
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${e.message}')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: BuildBackAppbar(
        title: 'Signup',
      ),
      body: Stack(
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (!_isVisible) ...[
                    buildTextField(
                      labelText: 'Email',
                      controller: _emailController,
                      onChanged: (value) {
                        _emailTimer?.cancel();
                        _emailTimer = Timer(Duration(seconds: 3), () {
                          if (value.length >= 3 && !value.contains('@')) {
                            _emailController.text = value + '@gmail.com';
                            _emailController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _emailController.text.length),
                            );
                          }
                        });
                      },
                    ),
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
                      onTap: () => _selectLevel(),
                      child: AbsorbPointer(
                        child: buildTextField(
                          labelText: 'Level',
                          controller: _LevelIdController..text = _selectedLevel ?? 'Select Level',
                          icon: Icons.arrow_forward_ios,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _selectRole(),
                      child: AbsorbPointer(
                        child: buildTextField(
                          labelText: 'Role',
                          controller: _roleIdController..text = _selectedRole ?? 'Select Role',
                          icon: Icons.arrow_forward_ios,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _selectDepartment(),
                      child: AbsorbPointer(
                        child: buildTextField(
                          labelText: 'Department',
                          controller: _departmentIdController..text = _selectedDepartment ?? 'Select Department',
                          icon: Icons.arrow_forward_ios,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>_selectStream(),
                      child: AbsorbPointer(
                        child: buildTextField(
                          labelText: 'Subjects',
                          controller: _subjectsController..text = _selectedSubjects.isEmpty
                              ? 'Select Subjects'
                              : _selectedSubjects.map((subject) => subject['name']).join(', '),
                          icon: Icons.arrow_forward_ios,
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    BuildButton(
                      text: 'Signup',
                      onPressed: _signUp,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void _clearInputFields() {
    _nameController.clear();
    _dobController.clear();
    _genderController.clear();
    _phoneController.clear();
    _roleIdController.clear();
    _departmentIdController.clear();
    _subjectsController.clear();
    _emailController.clear(); // Clear email controller
    _selectedRole = null;
    _selectedDepartment = null;
    _selectedSubjects.clear();
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
                              _selectedDepartmentId = department.id;
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
  void _selectLevel() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              _modalHeader('Select Level'),
              Expanded(
                child: StreamBuilder<List<CDModel>>(
                  stream: _levelService.getNames(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final levels = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: levels.length,
                      itemBuilder: (context, index) {
                        final level = levels[index];
                        return ListTile(
                          title: Text(level.name),
                          onTap: () {
                            setState(() {
                              _selectedLevel = level.name; // Store the selected department ID
                              _LevelIdController.text = level.id; // Display the department name
                              _selectedLevelId = level.id;
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
                    final departments = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: departments.length,
                      itemBuilder: (context, index) {
                        final department = departments[index];
                        return ListTile(
                          title: Text(department.name),
                          onTap: () {
                            setState(() {
                              _selectedRole = department.name; // Store the selected department ID
                              _roleIdController.text = department.id; // Display the department name
                              _selectRoleId = department.id;
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
  void _selectDate() async {
    DateTime currentDate = DateTime.now();

    DateTime? pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime tempDate = currentDate;
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

    if (pickedDate != null) {
      setState(() {
        _dobController.text = pickedDate.toIso8601String().split('T')[0];
      });
    }
  }

  void _selectStream() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              _modalHeader('Select Subjects'),
              Expanded(
                child: StreamBuilder<List<CDModel>>(
                  stream: _subjectService.getNames(), // Use the parameter here
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final subjects = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        // Check if the subject has already been selected
                        final isSelected = _selectedSubjects
                            .any((item) => item['id'] == subject.id);

                        return ListTile(
                          title: Text(subject.name),
                          trailing: isSelected ? Icon(Icons.check, color: Colors.green) : null, // Show check if selected
                          onTap:() {
                            setState(() {
                              if(isSelected){
                                _selectedSubjects.removeWhere(
                                        (item) => item['id'] == subject.id);
                              }else{
                                _selectedSubjects.add({
                                  'id': subject.id,
                                  'name': subject.name
                                });
                              }
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





  // void _selectStream() {
  //   showModalBottomSheet(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //         height: 250,
  //         child: Column(
  //           children: [
  //             _modalHeader('Select Subjects'),
  //             Expanded(
  //               child: StreamBuilder<List<CDModel>>(
  //                 stream: _subjectService.getNames(), // Use the parameter here
  //                 builder: (context, snapshot) {
  //                   if (snapshot.connectionState == ConnectionState.waiting) {
  //                     return Center(child: CircularProgressIndicator());
  //                   }
  //                   if (snapshot.hasError) {
  //                     return Center(child: Text('Error: ${snapshot.error}'));
  //                   }
  //                   final subjects = snapshot.data ?? [];
  //
  //                   return ListView.builder(
  //                     itemCount: subjects.length,
  //                     itemBuilder: (context, index) {
  //                       final subject = subjects[index];
  //                       return ListTile(
  //                         title: Text(subject.name),
  //                         onTap: () {
  //                           setState(() {
  //                             _selectedSubjects.add({'id': subject.id, 'name': subject.name});
  //                           });
  //                           Navigator.pop(context);
  //                         },
  //                       );
  //                     },
  //                   );
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }


  Widget _modalHeader(String title) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
