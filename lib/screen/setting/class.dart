import 'package:flutter/material.dart';
import 'package:som_mobile/const/app_color.dart';
import 'package:som_mobile/util/build_backappbar.dart';
import 'package:som_mobile/util/build_button.dart';
import '../../model/class_model.dart';
import '../../service/class_service.dart';
import '../../util/build_textfield.dart';

class ClassPage extends StatefulWidget {
  @override
  _ClassPageState createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  final NameService _nameService = NameService('class');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController(); // Search controller
  String? _selectedNameId;
  bool _isVisible = false; // Controls the visibility of the text field and button
  String _searchQuery = ''; // Store the current search query

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: BuildBackAppbar(
        title: 'Class',
        onActionPressed: () {
          setState(() {
            _isVisible = !_isVisible;
            if (!_isVisible) {
              _nameController.clear();
              _selectedNameId = null;
            }
          });
        },
        actionIcon: !_isVisible ? Icons.add : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
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
                labelText: 'Enter your name',
                controller: _nameController,
              ),
              BuildButton(
                text: _selectedNameId == null ? 'Add Name' : 'Update Name',
                onPressed: () async {
                  if (_selectedNameId == null) {
                    await _nameService.addName(CDModel(id: '', name: _nameController.text));
                  } else {
                    // Update
                    await _nameService.updateName(CDModel(id: _selectedNameId!, name: _nameController.text));
                    _selectedNameId = null; // Reset selection after update
                  }
                  _nameController.clear();
                  _isVisible = false;
                  setState(() {});
                },
              ),
            ],
            StreamBuilder<List<CDModel>>(
              stream: _nameService.getNames(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final names = snapshot.data ?? [];

                // Filter names based on the search query
                final filteredNames = names.where((name) =>
                    name.name.toLowerCase().contains(_searchQuery)).toList();

                return Expanded(
                  child: ListView.builder(
                    itemCount: filteredNames.length, // Use filtered list
                    itemBuilder: (context, index) {
                      final name = filteredNames[index]; // Get the name from filtered list
                      return GestureDetector(
                        onTap: () {
                          _isVisible = true;
                          _nameController.text = name.name; // Populate text field
                          _selectedNameId = name.id; // Set selected ID
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
                                    '${name.name}',
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
                                  await _nameService.deleteName(name.id);
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
