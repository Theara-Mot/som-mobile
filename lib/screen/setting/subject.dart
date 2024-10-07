import 'package:flutter/material.dart';
import 'package:som_mobile/const/app_color.dart';
import 'package:som_mobile/util/build_backappbar.dart';
import 'package:som_mobile/util/build_button.dart';
import '../../model/class_model.dart';
import '../../service/class_service.dart'; // Ensure this imports your SubjectService
import '../../util/build_textfield.dart';

class SubjectPage extends StatefulWidget {
  @override
  _SubjectPageState createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  final NameService _subjectService = NameService('subjects'); // Adjust your service as needed
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSubjectId;
  bool _isVisible = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: BuildBackAppbar(
        title: 'Subjects',
        onActionPressed: () {
          setState(() {
            _isVisible = !_isVisible;
            if (!_isVisible) {
              _subjectController.clear();
              _selectedSubjectId = null;
            }
          });
        },
        actionIcon: !_isVisible ? Icons.add : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (!_isVisible)
              buildTextField(
                labelText: 'Search',
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            SizedBox(height: 8),
            if (_isVisible) ...[
              buildTextField(
                labelText: 'Enter subject name',
                controller: _subjectController,
              ),
              BuildButton(
                text: _selectedSubjectId == null ? 'Add Subject' : 'Update Subject',
                onPressed: () async {
                  if (_selectedSubjectId == null) {
                    await _subjectService.addName(CDModel(id: '', name: _subjectController.text));
                  } else {
                    // Update
                    await _subjectService.updateName(CDModel(id: _selectedSubjectId!, name: _subjectController.text));
                    _selectedSubjectId = null; // Reset selection after update
                  }
                  _subjectController.clear();
                  _isVisible = false;
                  setState(() {});
                },
              ),
            ],
            StreamBuilder<List<CDModel>>(
              stream: _subjectService.getNames(), // Adjust stream to get subjects
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final subjects = snapshot.data ?? [];

                // Filter subjects based on the search query
                final filteredSubjects = subjects.where((subject) =>
                    subject.name.toLowerCase().contains(_searchQuery)).toList();

                return Expanded(
                  child: ListView.builder(
                    itemCount: filteredSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = filteredSubjects[index];
                      return GestureDetector(
                        onTap: () {
                          _isVisible = true;
                          _subjectController.text = subject.name;
                          _selectedSubjectId = subject.id;
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
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 15,
                                    child: Text('${index + 1}'),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${subject.name}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  await _subjectService.deleteName(subject.id); // Adjust delete method as needed
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
}
