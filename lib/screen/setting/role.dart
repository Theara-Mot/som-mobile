import 'package:flutter/material.dart';
import 'package:som_mobile/const/app_color.dart';
import 'package:som_mobile/util/build_backappbar.dart';
import 'package:som_mobile/util/build_button.dart';
import '../../model/class_model.dart';
import '../../service/class_service.dart'; // Ensure this imports your RoleService
import '../../util/build_textfield.dart';

class RolePage extends StatefulWidget {
  @override
  _RolePageState createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  final NameService _roleService = NameService('roles'); // Adjust your service as needed
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRoleId;
  bool _isVisible = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: BuildBackAppbar(
        title: 'Roles',
        onActionPressed: () {
          setState(() {
            _isVisible = !_isVisible;
            if (!_isVisible) {
              _roleController.clear();
              _selectedRoleId = null;
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
                labelText: 'Enter role name',
                controller: _roleController,
              ),
              BuildButton(
                text: _selectedRoleId == null ? 'Add Role' : 'Update Role',
                onPressed: () async {
                  if (_selectedRoleId == null) {
                    await _roleService.addName(CDModel(id: '', name: _roleController.text));
                  } else {
                    // Update
                    await _roleService.updateName(CDModel(id: _selectedRoleId!, name: _roleController.text));
                    _selectedRoleId = null; // Reset selection after update
                  }
                  _roleController.clear();
                  _isVisible = false;
                  setState(() {});
                },
              ),
            ],
            StreamBuilder<List<CDModel>>(
              stream: _roleService.getNames(), // Adjust stream to get roles
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final roles = snapshot.data ?? [];

                // Filter roles based on the search query
                final filteredRoles = roles.where((role) =>
                    role.name.toLowerCase().contains(_searchQuery)).toList();

                return Expanded(
                  child: ListView.builder(
                    itemCount: filteredRoles.length,
                    itemBuilder: (context, index) {
                      final role = filteredRoles[index];
                      return GestureDetector(
                        onTap: () {
                          _isVisible = true;
                          _roleController.text = role.name;
                          _selectedRoleId = role.id;
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
                                    '${role.name}',
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
                                  await _roleService.deleteName(role.id); // Adjust delete method as needed
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
