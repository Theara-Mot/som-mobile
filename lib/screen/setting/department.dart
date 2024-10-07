import 'package:flutter/material.dart';
import 'package:som_mobile/const/app_color.dart';
import 'package:som_mobile/util/build_backappbar.dart';
import 'package:som_mobile/util/build_button.dart';
import '../../model/class_model.dart';
import '../../service/class_service.dart';
import '../../util/build_textfield.dart';

class DepartmentPage extends StatefulWidget {
  @override
  _DepartmentPageState createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  final NameService _departmentService = NameService('departments'); // Adjust your service as needed
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController(); // Search controller
  String? _selectedDepartmentId;
  bool _isVisible = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: BuildBackAppbar(
        title: 'Department',
        onActionPressed: () {
          setState(() {
            _isVisible = !_isVisible;
            if (!_isVisible) {
              _departmentController.clear();
              _selectedDepartmentId = null;
            }
          });
        },
        actionIcon: !_isVisible ? Icons.add : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if(!_isVisible)
              buildTextField(
                labelText: 'Search',
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase(); // Update the search query
                  });
                },
              ),
            SizedBox(height: 8), // Space between search field and other components
            if (_isVisible) ...[
              buildTextField(
                labelText: 'Enter department name',
                controller: _departmentController,
              ),
              BuildButton(
                text: _selectedDepartmentId == null ? 'Add Department' : 'Update Department',
                onPressed: () async {
                  if (_selectedDepartmentId == null) {
                    await _departmentService.addName(CDModel(id: '', name: _departmentController.text));
                  } else {
                    // Update
                    await _departmentService.updateName(CDModel(id: _selectedDepartmentId!, name: _departmentController.text));
                    _selectedDepartmentId = null; // Reset selection after update
                  }
                  _departmentController.clear();
                  _isVisible = false;
                  setState(() {});
                },
              ),
            ],
            StreamBuilder<List<CDModel>>(
              stream: _departmentService.getNames(), // Adjust stream to get departments
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final departments = snapshot.data ?? [];

                // Filter departments based on the search query
                final filteredDepartments = departments.where((department) =>
                    department.name.toLowerCase().contains(_searchQuery)).toList();

                return Expanded(
                  child: ListView.builder(
                    itemCount: filteredDepartments.length, // Use filtered list
                    itemBuilder: (context, index) {
                      final department = filteredDepartments[index]; // Get the department from filtered list
                      return GestureDetector(
                        onTap: () {
                          _isVisible = true;
                          _departmentController.text = department.name; // Populate text field
                          _selectedDepartmentId = department.id; // Set selected ID
                          setState(() {}); // Update the state to reflect changes
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          margin: EdgeInsets.only(bottom: 8), // Space between containers
                          decoration: BoxDecoration(
                            color: Colors.white, // Background color of the container
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3), // Changes position of shadow
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
                                    child: Text('${index + 1}'), // Close the string correctly
                                    backgroundColor: Colors.blue, // You can customize the background color
                                    foregroundColor: Colors.white, // Text color in the CircleAvatar
                                  ),
                                  SizedBox(width: 8), // Add some space between the avatar and the text
                                  Text(
                                    '${department.name}',
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
                                  await _departmentService.deleteName(department.id); // Adjust delete method as needed
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
